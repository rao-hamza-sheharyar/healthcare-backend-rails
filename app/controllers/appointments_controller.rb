class AppointmentsController < ApplicationController
  # ApplicationController already includes Authenticable
  # So authenticate_request is already a before_action for all actions by default
  
  skip_before_action :authenticate_request, only: [:index]
  before_action :authenticate_optional, only: [:index]
  # Note: create action will use authenticate_request from Authenticable module
  
  before_action :set_appointment, only: [:show, :update, :destroy, :approve, :reject, :cancel, :reschedule, :request_reschedule, :approve_reschedule_request, :reject_reschedule_request]
  before_action :require_appointment_owner_or_admin, only: [:show, :update, :destroy, :request_reschedule]
  before_action :require_doctor_owner, only: [:approve, :reject, :approve_reschedule_request, :reject_reschedule_request]
  before_action :require_reschedule_permission, only: [:reschedule]
  
  def index
    # Public access for doctor_id filter (for doctor profile stats)
    if params[:doctor_id].present? && params[:status] == 'approved'
      @appointments = Appointment.where(doctor_id: params[:doctor_id], status: 'approved')
                                 .includes(:user)
                                 .limit(20) # Limit for public view
      render json: @appointments.map { |a| {
        id: a.id,
        user: { full_name: a.user.full_name },
        appointment_date: a.appointment_date,
        status: a.status
      } }
      return
    end
    
    # Authenticated access
    authenticate_request unless current_user
    return unless current_user
    
    if current_user.admin?
      @appointments = Appointment.includes(:user, :doctor)
    elsif current_user.doctor
      @appointments = current_user.doctor.appointments.includes(:user)
    else
      @appointments = current_user.appointments.includes(:doctor)
    end
    
    status_filter = params[:status]
    @appointments = @appointments.where(status: status_filter) if status_filter.present?
    
    render json: @appointments.map { |a| appointment_json(a) }
  end
  
  def show
    render json: appointment_json(@appointment)
  end
  
  def create
    # authenticate_request should have already set current_user via before_action
    # Log for debugging
    Rails.logger.info "=== APPOINTMENT CREATE ACTION CALLED ==="
    Rails.logger.info "Authorization header present: #{request.headers['Authorization'].present?}"
    Rails.logger.info "Authorization header: #{request.headers['Authorization']}"
    Rails.logger.info "@current_user instance variable: #{@current_user&.email || 'nil'}"
    Rails.logger.info "current_user method result: #{current_user&.email || 'nil'}"
    Rails.logger.info "Current user ID: #{current_user&.id || 'nil'}"
    Rails.logger.info "Appointment params: #{params[:appointment].inspect}"
    
    # Double-check authentication (authenticate_request should have handled this)
    unless current_user.present?
      Rails.logger.error "❌ ====== AUTHENTICATION FAILED ======"
      Rails.logger.error "❌ current_user is nil after authenticate_request before_action!"
      Rails.logger.error "❌ This means authenticate_request either:"
      Rails.logger.error "   1. Wasn't called"
      Rails.logger.error "   2. Was called but didn't set @current_user"
      Rails.logger.error "   3. Was called but didn't return early on error"
      Rails.logger.error "❌ Authorization header: #{request.headers['Authorization']}"
      Rails.logger.error "❌ @current_user value: #{@current_user.inspect}"
      render json: { errors: ['User must be logged in'], message: 'Please login again' }, status: :unauthorized
      return
    end
    
    @appointment = Appointment.new(appointment_params)
    @appointment.user = current_user
    
    # Validate doctor exists
    unless @appointment.doctor.present?
      render json: { errors: ['Doctor not found'] }, status: :unprocessable_entity
      return
    end
    
    # Ensure user_id is explicitly set
    @appointment.user_id = current_user.id
    
    if @appointment.save
      # Appointment created as 'pending' - email will be sent when doctor approves
      render json: appointment_json(@appointment), status: :created
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    if @appointment.update(appointment_params)
      render json: appointment_json(@appointment)
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @appointment.destroy
    head :no_content
  end
  
  def approve
    @appointment.approve!
    # Send confirmation email when doctor approves
    begin
      UserMailer.appointment_confirmation(@appointment).deliver_now
      Rails.logger.info "✅ Appointment confirmation email sent to #{@appointment.user.email}"
    rescue => e
      Rails.logger.error "❌ Failed to send appointment confirmation email: #{e.message}"
    end
    render json: appointment_json(@appointment)
  end
  
  def reject
    reason = params[:rejection_reason]
    if reason.blank?
      render json: { error: 'Rejection reason is required' }, status: :unprocessable_entity
      return
    end
    
    @appointment.reject!(reason)
    # Send status update email
    begin
      UserMailer.appointment_status_update(@appointment).deliver_later
    rescue => e
      Rails.logger.error "Failed to send appointment status email: #{e.message}"
    end
    render json: appointment_json(@appointment)
  end
  
  def cancel
    unless @appointment.user == current_user || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
      return
    end
    
    if @appointment.status == 'approved' && @appointment.appointment_date > Time.current
      @appointment.update(status: 'cancelled')
      # Send cancellation email
      begin
        UserMailer.appointment_status_update(@appointment).deliver_later
      rescue => e
        Rails.logger.error "Failed to send appointment cancellation email: #{e.message}"
      end
      render json: appointment_json(@appointment)
    else
      render json: { error: 'Appointment cannot be cancelled' }, status: :unprocessable_entity
    end
  end

  def reschedule
    new_date = params[:appointment_date]
    
    if new_date.blank?
      render json: { error: 'New appointment date is required' }, status: :unprocessable_entity
      return
    end

    parsed_date = Time.zone.parse(new_date)
    
    if parsed_date.nil? || parsed_date <= Time.current
      render json: { error: 'Appointment date must be in the future' }, status: :unprocessable_entity
      return
    end

    # Doctor rescheduling: Update date/time and approve the appointment
    # Before approval: Direct reschedule (update appointment, approve it)
    # After approval: User must request reschedule (handled in request_reschedule action)
    if @appointment.status == 'pending'
      old_date = @appointment.appointment_date
      @appointment.appointment_date = parsed_date
      @appointment.status = 'approved' # Automatically approve when doctor reschedules
      
      if @appointment.save
        # Send appointment confirmation email (same as approve action)
        begin
          UserMailer.appointment_confirmation(@appointment).deliver_now
          Rails.logger.info "✅ Appointment rescheduled and approved - confirmation email sent to #{@appointment.user.email}"
        rescue => e
          Rails.logger.error "❌ Failed to send appointment confirmation email: #{e.message}"
        end
        render json: appointment_json(@appointment)
      else
        render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      # For approved appointments, user must use request_reschedule endpoint
      render json: { error: 'Approved appointments require a reschedule request. Use request_reschedule endpoint.' }, status: :unprocessable_entity
    end
  end
  
  def request_reschedule
    # Only for approved appointments - patient requests reschedule with reason
    unless @appointment.status == 'approved'
      render json: { error: 'Only approved appointments can request reschedule' }, status: :unprocessable_entity
      return
    end
    
    new_date = params[:appointment_date]
    reason = params[:reschedule_reason]
    
    if new_date.blank?
      render json: { error: 'New appointment date is required' }, status: :unprocessable_entity
      return
    end
    
    if reason.blank?
      render json: { error: 'Reschedule reason is required' }, status: :unprocessable_entity
      return
    end

    parsed_date = Time.zone.parse(new_date)
    
    if parsed_date.nil? || parsed_date <= Time.current
      render json: { error: 'Appointment date must be in the future' }, status: :unprocessable_entity
      return
    end
    
    @appointment.request_reschedule!(parsed_date, reason)
    
    if @appointment.save
      # Send reschedule request email to doctor
      begin
        UserMailer.reschedule_requested(@appointment).deliver_now
        Rails.logger.info "✅ Reschedule request email sent"
      rescue => e
        Rails.logger.error "❌ Failed to send reschedule request email: #{e.message}"
      end
      render json: appointment_json(@appointment)
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def approve_reschedule_request
    # Doctor approves reschedule request
    unless (current_user.doctor && current_user.doctor == @appointment.doctor) || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
      return
    end
    
    unless @appointment.reschedule_status == 'pending'
      render json: { error: 'No pending reschedule request' }, status: :unprocessable_entity
      return
    end
    
    old_date = @appointment.approve_reschedule_request!
    
    if old_date
      # Send email notification
      begin
        UserMailer.reschedule_approved(@appointment, old_date).deliver_now
        Rails.logger.info "✅ Reschedule approval email sent"
      rescue => e
        Rails.logger.error "❌ Failed to send reschedule approval email: #{e.message}"
      end
      render json: appointment_json(@appointment)
    else
      render json: { error: 'Failed to approve reschedule request' }, status: :unprocessable_entity
    end
  end
  
  def reject_reschedule_request
    # Doctor rejects reschedule request
    unless (current_user.doctor && current_user.doctor == @appointment.doctor) || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
      return
    end
    
    unless @appointment.reschedule_status == 'pending'
      render json: { error: 'No pending reschedule request' }, status: :unprocessable_entity
      return
    end
    
    @appointment.reject_reschedule_request!
    
    # Send email notification
    begin
      UserMailer.reschedule_rejected(@appointment).deliver_now
      Rails.logger.info "✅ Reschedule rejection email sent"
    rescue => e
      Rails.logger.error "❌ Failed to send reschedule rejection email: #{e.message}"
    end
    
    render json: appointment_json(@appointment)
  end
  
  private
  
  def set_appointment
    @appointment = Appointment.find(params[:id])
  end
  
  def require_appointment_owner_or_admin
    unless current_user == @appointment.user || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
  
  def require_doctor_owner
    unless (current_user.doctor && current_user.doctor == @appointment.doctor) || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end

  def require_reschedule_permission
    # Allow rescheduling if:
    # 1. User is the appointment owner (patient)
    # 2. User is the doctor for this appointment
    # 3. User is an admin
    unless (@appointment.user == current_user) || 
           (current_user.doctor && current_user.doctor == @appointment.doctor) || 
           current_user.admin?
      render json: { error: 'Not authorized to reschedule this appointment' }, status: :forbidden
    end
  end
  
  def appointment_params
    params.require(:appointment).permit(:doctor_id, :appointment_date, :notes).tap do |whitelisted|
      # Convert doctor_id to integer if it's a string
      if whitelisted[:doctor_id].present?
        whitelisted[:doctor_id] = whitelisted[:doctor_id].to_i
        # Ensure doctor exists
        doctor = Doctor.find_by(id: whitelisted[:doctor_id])
        unless doctor
          Rails.logger.error "❌ Doctor not found - ID: #{whitelisted[:doctor_id]}"
          raise ActiveRecord::RecordNotFound, "Doctor not found"
        end
      end
    end
  end
  
  def appointment_json(appointment)
    {
      id: appointment.id,
      user: {
        id: appointment.user.id,
        full_name: appointment.user.full_name,
        email: appointment.user.email,
        phone: appointment.user.phone
      },
      doctor: {
        id: appointment.doctor.id,
        specialization: appointment.doctor.specialization,
        user: {
          full_name: appointment.doctor.user.full_name
        }
      },
      appointment_date: appointment.appointment_date,
      status: appointment.status,
      rejection_reason: appointment.rejection_reason,
      notes: appointment.notes,
      reschedule_requested_date: appointment.reschedule_requested_date,
      reschedule_reason: appointment.reschedule_reason,
      reschedule_status: appointment.reschedule_status,
      created_at: appointment.created_at,
      updated_at: appointment.updated_at
    }
  end
end


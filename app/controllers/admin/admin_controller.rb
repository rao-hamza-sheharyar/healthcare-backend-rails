class Admin::AdminController < ApplicationController
  include Authenticable
  before_action :authenticate_request
  before_action :require_admin
  
  def analytics
    stats = {
      total_users: User.count,
      total_patients: User.patients.count,
      total_doctors: Doctor.count,
      total_appointments: Appointment.count,
      pending_appointments: Appointment.pending.count,
      approved_appointments: Appointment.approved.count,
      rejected_appointments: Appointment.rejected.count,
      total_reviews: Review.count,
      average_doctor_rating: (Doctor.average(:rating) || 0.0).to_f
    }
    
    render json: stats
  end
  
  def book_appointment_for_client
    user = User.find(params[:user_id])
    doctor = Doctor.find(params[:doctor_id])
    
    @appointment = Appointment.new(
      user: user,
      doctor: doctor,
      appointment_date: params[:appointment_date],
      notes: params[:notes],
      status: 'pending' # Admin bookings also wait for doctor approval
    )
    
    if @appointment.save
      # Appointment created as 'pending' - email will be sent when doctor approves
      Rails.logger.info "✅ Appointment created (pending) for patient #{user.email}"
      
      render json: {
        id: @appointment.id,
        user: { 
          id: user.id,
          full_name: user.full_name,
          email: user.email 
        },
        doctor: { 
          id: doctor.id,
          specialization: doctor.specialization,
          user: {
            full_name: doctor.user.full_name
          }
        },
        appointment_date: @appointment.appointment_date,
        status: @appointment.status,
        notes: @appointment.notes,
        created_at: @appointment.created_at
      }, status: :created
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end
end


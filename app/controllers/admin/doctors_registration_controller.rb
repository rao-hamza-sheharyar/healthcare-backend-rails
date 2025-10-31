class Admin::DoctorsRegistrationController < ApplicationController
  include Authenticable
  before_action :authenticate_request
  before_action :require_admin
  
  def create
    # Admin can create a doctor for any user or create new user+doctor
    if params[:user_id]
      # Create doctor for existing user
      user = User.find(params[:user_id])
      if user.doctor.present?
        render json: { error: 'User already has a doctor profile' }, status: :unprocessable_entity
        return
      end
    else
      # Create new user first
      user = User.new(user_params)
      user.role = 'doctor'
      generated_password = SecureRandom.hex(8)
      user.password = generated_password if user.password_digest.blank?
      
      unless user.save
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        return
      end
      # Send welcome email with credentials
      begin
        UserMailer.welcome_email(user, generated_password).deliver_now
      rescue => e
        Rails.logger.error "Failed to send welcome email: #{e.message}"
      end
    end
    
    doctor = Doctor.new(doctor_params)
    doctor.user = user
    
    if doctor.save
      response_data = {
        doctor: {
          id: doctor.id,
          specialization: doctor.specialization,
          description: doctor.description,
          qualifications: doctor.qualifications,
          experience_years: doctor.experience_years,
          rating: doctor.rating.to_f,
          total_reviews: doctor.total_reviews,
          license_number: doctor.license_number,
          user: {
            id: user.id,
            full_name: user.full_name,
            email: user.email
          }
        },
        message: 'Doctor created. Login credentials sent via email.'
      }
      # Include password if it was generated (only for new users)
      if params[:user_id].blank? && generated_password.present?
        response_data[:password] = generated_password
        response_data[:email] = user.email
      end
      render json: response_data, status: :created
    else
      render json: { errors: doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name, :phone, :address) if params[:user].present?
  end
  
  def doctor_params
    params.require(:doctor).permit(:specialization, :description, :qualifications, :experience_years, :license_number)
  end
end


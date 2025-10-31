class DoctorsRegistrationController < ApplicationController
  include Authenticable
  before_action :authenticate_request
  
  def create
    user = current_user
    
    # Check if user already has a doctor profile
    if user.doctor.present?
      render json: { error: 'Doctor profile already exists' }, status: :unprocessable_entity
      return
    end
    
    doctor = Doctor.new(doctor_params)
    doctor.user = user
    
    if doctor.save
      user.update(role: 'doctor') if user.role == 'patient'
      render json: {
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
        }
      }, status: :created
    else
      render json: { errors: doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def doctor_params
    params.require(:doctor).permit(:specialization, :description, :qualifications, :experience_years, :license_number)
  end
end


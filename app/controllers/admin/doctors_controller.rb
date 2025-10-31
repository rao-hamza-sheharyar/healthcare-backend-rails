class Admin::DoctorsController < ApplicationController
  include Authenticable
  before_action :authenticate_request
  before_action :require_admin
  
  def index
    @doctors = Doctor.includes(:user).all
    render json: @doctors.map { |d| doctor_json(d) }
  end
  
  def update
    @doctor = Doctor.find(params[:id])
    if @doctor.update(doctor_params)
      render json: doctor_json(@doctor)
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @doctor = Doctor.find(params[:id])
    @doctor.destroy
    head :no_content
  end
  
  private
  
  def doctor_params
    params.require(:doctor).permit(:specialization, :description, :qualifications, :experience_years, :license_number)
  end
  
  def doctor_json(doctor)
    {
      id: doctor.id,
      user: {
        id: doctor.user.id,
        email: doctor.user.email,
        first_name: doctor.user.first_name,
        last_name: doctor.user.last_name,
        full_name: doctor.user.full_name
      },
      specialization: doctor.specialization,
      description: doctor.description,
      qualifications: doctor.qualifications,
      experience_years: doctor.experience_years,
      rating: doctor.rating.to_f,
      total_reviews: doctor.total_reviews,
      license_number: doctor.license_number
    }
  end
end



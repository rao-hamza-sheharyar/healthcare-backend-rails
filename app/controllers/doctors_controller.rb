class DoctorsController < ApplicationController
  include Authenticable
  skip_before_action :authenticate_request, only: [:index, :show, :search]
  before_action :authenticate_optional, only: [:index, :show, :search]
  before_action :authenticate_request, only: [:update]
  
  before_action :set_doctor, only: [:show, :update]
  before_action :require_doctor_owner, only: [:update]
  
  def index
    @doctors = Doctor.includes(:user)
                     .order(rating: :desc, total_reviews: :desc)
                     .limit(params[:limit] || 10)
    
    render json: @doctors.map { |d| doctor_json(d) }
  end
  
  def show
    render json: doctor_json(@doctor)
  end
  
  def search
    query = params[:query] || ''
    specialization = params[:specialization]
    
    @doctors = Doctor.includes(:user)
    
    if query.present?
      @doctors = @doctors.joins(:user)
                        .where("users.first_name LIKE ? OR users.last_name LIKE ? OR doctors.specialization LIKE ? OR doctors.description LIKE ?",
                               "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
    end
    
    if specialization.present?
      @doctors = @doctors.where("specialization LIKE ?", "%#{specialization}%")
    end
    
    @doctors = @doctors.order(rating: :desc)
    
    render json: @doctors.map { |d| doctor_json(d) }
  end
  
  def update
    if @doctor.update(doctor_params)
      render json: doctor_json(@doctor)
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_doctor
    @doctor = Doctor.find(params[:id])
  end
  
  def require_doctor_owner
    unless (current_user.doctor && current_user.doctor == @doctor) || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
  
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
        full_name: doctor.user.full_name,
        phone: doctor.user.phone
      },
      specialization: doctor.specialization,
      description: doctor.description,
      qualifications: doctor.qualifications,
      experience_years: doctor.experience_years,
      rating: doctor.rating.to_f,
      total_reviews: doctor.total_reviews,
      license_number: doctor.license_number,
      created_at: doctor.created_at
    }
  end
end


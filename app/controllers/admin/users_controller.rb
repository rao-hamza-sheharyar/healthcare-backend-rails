class Admin::UsersController < ApplicationController
  include Authenticable
  before_action :authenticate_request
  before_action :require_admin
  
  def index
    role_filter = params[:role]
    @users = User.includes(:doctor)
    
    @users = @users.where(role: role_filter) if role_filter.present?
    
    render json: @users.map { |u| user_json(u) }
  end
  
  def show
    @user = User.find(params[:id])
    render json: user_json(@user)
  end
  
  def create
    @user = User.new(user_params)
    @user.role = params[:role] || 'patient'
    generated_password = SecureRandom.hex(8)
    @user.password = generated_password if @user.password_digest.blank?
    
    if @user.save
      # Send welcome email with credentials
      begin
        UserMailer.welcome_email(@user, generated_password).deliver_now
      rescue => e
        Rails.logger.error "Failed to send welcome email: #{e.message}"
      end
      
      response_data = user_json(@user)
      response_data[:password] = generated_password
      response_data[:message] = 'User created. Login credentials sent via email.'
      render json: response_data, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params.except(:password))
      if params[:password].present?
        @user.update(password: params[:password])
      end
      render json: user_json(@user)
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    head :no_content
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name, :phone, :address, :role)
  end
  
  def user_json(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      phone: user.phone,
      address: user.address,
      role: user.role,
      doctor: user.doctor ? {
        id: user.doctor.id,
        specialization: user.doctor.specialization,
        rating: user.doctor.rating.to_f
      } : nil
    }
  end
end


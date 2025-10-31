class UsersController < ApplicationController
  include Authenticable
  before_action :authenticate_request
  
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :require_user_owner_or_admin, only: [:show, :update]
  before_action :require_admin, only: [:index, :create, :destroy]
  
  def me
    render json: user_json(current_user)
  end
  
  def update_me
    if current_user.update(user_params.except(:password, :role))
      if params[:password].present?
        current_user.update(password: params[:password])
      end
      render json: user_json(current_user)
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def index
    role_filter = params[:role]
    @users = User.includes(:doctor)
    
    @users = @users.where(role: role_filter) if role_filter.present?
    
    render json: @users.map { |u| user_json(u) }
  end
  
  def show
    render json: user_json(@user)
  end
  
  def create
    @user = User.new(user_params)
    @user.role = params[:role] || 'client'
    @user.password = SecureRandom.hex(8) if @user.password_digest.blank?
    
    if @user.save
      # TODO: Send email with login credentials
      render json: user_json(@user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
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
    @user.destroy
    head :no_content
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def require_user_owner_or_admin
    unless current_user == @user || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
  
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

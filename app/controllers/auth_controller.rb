class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]
  
  def register
    user = User.new(user_params)
    user.role = params[:role] || 'patient'
    
    if user.save
      token = JwtService.encode({ user_id: user.id })
      render json: {
        user: user_json(user),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: user.id })
      render json: {
        user: user_json(user),
        token: token
      }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
  
  def me
    authenticate_request
    render json: { user: user_json(current_user) }
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name, :phone, :address)
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


class PasswordResetsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :update]
  
  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_password_reset_token!
      UserMailer.password_reset_email(user, user.reset_token).deliver_later
      render json: { message: 'Password reset instructions sent to your email' }
    else
      # Don't reveal if email exists
      render json: { message: 'If the email exists, password reset instructions have been sent' }
    end
  end
  
  def update
    user = User.find_by(reset_token: params[:token])
    
    unless user && user.password_reset_token_valid?
      render json: { error: 'Invalid or expired reset token' }, status: :unprocessable_entity
      return
    end
    
    if params[:password].blank? || params[:password].length < 6
      render json: { error: 'Password must be at least 6 characters' }, status: :unprocessable_entity
      return
    end
    
    if user.update(password: params[:password])
      user.clear_password_reset_token!
      render json: { message: 'Password reset successfully' }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end



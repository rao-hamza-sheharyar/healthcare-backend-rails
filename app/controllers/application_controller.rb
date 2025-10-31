class ApplicationController < ActionController::API
  include Authenticable
  
  protected
  
  def authenticate_optional
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token
    
    decoded = JwtService.decode(token)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded
  end
  
  def current_user
    @current_user
  end
end


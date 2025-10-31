module Authenticable
  extend ActiveSupport::Concern
  
  included do
    before_action :authenticate_request
  end
  
  private
  
  def authenticate_request
    Rails.logger.info "=== AUTHENTICATE REQUEST ==="
    Rails.logger.info "Request path: #{request.path}"
    Rails.logger.info "Request method: #{request.method}"
    Rails.logger.info "Authorization header: #{request.headers['Authorization']}"
    Rails.logger.info "HTTP_AUTHORIZATION header: #{request.headers['HTTP_AUTHORIZATION']}"
    Rails.logger.info "All headers containing 'auth': #{request.headers.select { |k, v| k.to_s.downcase.include?('auth') }.inspect}"
    
    token = extract_token_from_header
    Rails.logger.info "Extracted token: #{token ? token[0..20] + '...' : 'nil'}"
    
    if token.nil?
      Rails.logger.error "❌ Missing token - Authorization header: #{request.headers['Authorization']}"
      render json: { errors: ['Missing token'], error: 'Please login again' }, status: :unauthorized
      return false # Explicitly return false to stop execution
    end
    
    decoded = JwtService.decode(token)
    if decoded.nil?
      Rails.logger.error "❌ Invalid token - Token decode failed"
      Rails.logger.error "❌ Token value: #{token[0..50]}..."
      render json: { errors: ['Invalid or expired token'], error: 'Please login again' }, status: :unauthorized
      return false
    end
    
    Rails.logger.info "✅ Token decoded - User ID: #{decoded[:user_id]}"
    
    @current_user = User.find_by(id: decoded[:user_id])
    if @current_user.nil?
      Rails.logger.error "❌ User not found - User ID: #{decoded[:user_id]}"
      render json: { errors: ['User not found'], error: 'Please login again' }, status: :unauthorized
      return false
    end
    
    Rails.logger.info "✅ Authentication successful - User: #{@current_user.email}, Role: #{@current_user.role}"
    true # Return true to indicate success
  end
  
  def extract_token_from_header
    # Try Authorization header first, then HTTP_AUTHORIZATION (for some proxies)
    auth_header = request.headers['Authorization'] || request.headers['HTTP_AUTHORIZATION']
    return nil if auth_header.nil? || auth_header.empty?
    
    # Handle "Bearer token" format
    if auth_header.starts_with?('Bearer ')
      auth_header.split(' ').last
    elsif auth_header.starts_with?('bearer ')
      # Case-insensitive check
      auth_header.split(' ').last
    else
      # Assume the header itself is the token (for backwards compatibility)
      auth_header
    end
  end
  
  def current_user
    @current_user
  end
  
  def require_admin
    unless current_user&.admin?
      render json: { error: 'Admin access required' }, status: :forbidden
    end
  end
end


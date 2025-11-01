class JwtService
  def self.secret_key
    # Rails 8.1 removed Rails.application.secrets - use secret_key_base directly
    Rails.application.secret_key_base || ENV['SECRET_KEY_BASE'] || 'development-secret-key-change-in-production-use-credentials'
  end
  
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key)
  end
  
  def self.decode(token)
    decoded = JWT.decode(token, secret_key)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    nil
  end
end


class JwtService
  def self.secret_key
    if Rails.application.credentials.secret_key_base.present?
      Rails.application.credentials.secret_key_base
    elsif Rails.application.secrets.secret_key_base.present?
      Rails.application.secrets.secret_key_base
    else
      # Fallback for development - in production, use credentials or env variable
      ENV['SECRET_KEY_BASE'] || 'development-secret-key-change-in-production-use-credentials'
    end
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


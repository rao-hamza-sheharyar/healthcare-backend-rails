class User < ApplicationRecord
  has_secure_password
  
  has_one :doctor, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, inclusion: { in: %w[patient admin doctor] }
  
  scope :patients, -> { where(role: 'patient') }
  scope :admins, -> { where(role: 'admin') }
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def admin?
    role == 'admin'
  end
  
  def patient?
    role == 'patient'
  end
  
  # Keep client? method for backwards compatibility
  def client?
    role == 'patient'
  end
  
  def doctor?
    doctor.present?
  end

  def generate_password_reset_token!
    self.reset_token = SecureRandom.urlsafe_base64(32)
    self.reset_token_sent_at = Time.current
    save(validate: false)
  end

  def password_reset_token_valid?
    reset_token_sent_at.present? && reset_token_sent_at > 1.hour.ago
  end

  def clear_password_reset_token!
    self.reset_token = nil
    self.reset_token_sent_at = nil
    save(validate: false)
  end
end


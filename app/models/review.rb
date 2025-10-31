class Review < ApplicationRecord
  belongs_to :user
  belongs_to :doctor
  belongs_to :appointment, optional: true
  
  validates :rating, presence: true, numericality: { in: 1..5 }
  # Prevent duplicate reviews for the same appointment
  # But allow multiple reviews per user-doctor if appointment_id is nil
  validates :appointment_id, uniqueness: { scope: [:user_id], message: "has already been reviewed" }, allow_nil: true
  
  after_save :update_doctor_rating
  after_destroy :update_doctor_rating
  
  private
  
  def update_doctor_rating
    doctor.update_rating
  end
end


class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :doctor
  
  validates :appointment_date, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected cancelled] }
  validates :reschedule_status, inclusion: { in: %w[pending approved rejected] }, allow_nil: true
  
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :upcoming, -> { where('appointment_date > ?', Time.current) }
  scope :with_pending_reschedule, -> { where(reschedule_status: 'pending') }
  
  def approve!(reason = nil)
    update(status: 'approved', rejection_reason: nil)
  end
  
  def reject!(reason)
    update(status: 'rejected', rejection_reason: reason)
  end
  
  def request_reschedule!(new_date, reason)
    update(
      reschedule_requested_date: new_date,
      reschedule_reason: reason,
      reschedule_status: 'pending'
    )
  end
  
  def approve_reschedule_request!
    if reschedule_status == 'pending' && reschedule_requested_date.present?
      old_date = appointment_date
      update(
        appointment_date: reschedule_requested_date,
        status: 'pending', # Change status back to pending
        reschedule_status: 'approved',
        reschedule_requested_date: nil,
        reschedule_reason: nil
      )
      old_date
    else
      nil
    end
  end
  
  def reject_reschedule_request!
    update(
      reschedule_status: 'rejected',
      reschedule_requested_date: nil,
      reschedule_reason: nil
    )
  end
end


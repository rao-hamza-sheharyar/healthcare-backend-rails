class AddRescheduleRequestToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :reschedule_requested_date, :datetime
    add_column :appointments, :reschedule_reason, :text
    add_column :appointments, :reschedule_status, :string, default: nil # nil, pending, approved, rejected
  end
end



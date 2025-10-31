class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.datetime :appointment_date, null: false
      t.string :status, default: 'pending', null: false # pending, approved, rejected
      t.text :rejection_reason
      t.text :notes
      t.timestamps
    end
    
    add_index :appointments, :appointment_date
    add_index :appointments, :status
  end
end



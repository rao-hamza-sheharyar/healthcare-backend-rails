class CreateDoctors < ActiveRecord::Migration[8.1]
  def change
    create_table :doctors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :specialization, null: false
      t.text :description
      t.string :qualifications
      t.integer :experience_years, default: 0
      t.decimal :rating, precision: 3, scale: 2, default: 0.0
      t.integer :total_reviews, default: 0
      t.string :license_number
      t.timestamps
    end
  end
end



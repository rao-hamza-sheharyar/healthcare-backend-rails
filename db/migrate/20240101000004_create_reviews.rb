class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true
      t.references :appointment, foreign_key: true # Optional link to appointment
      t.integer :rating, null: false # 1-5
      t.text :comment
      t.timestamps
    end
    
    add_index :reviews, [:doctor_id, :user_id]
  end
end



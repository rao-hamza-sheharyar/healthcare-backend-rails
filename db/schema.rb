# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2024_01_01_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.datetime "appointment_date", null: false
    t.datetime "created_at", null: false
    t.bigint "doctor_id", null: false
    t.text "notes"
    t.text "rejection_reason"
    t.text "reschedule_reason"
    t.datetime "reschedule_requested_date"
    t.string "reschedule_status"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["appointment_date"], name: "index_appointments_on_appointment_date"
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["status"], name: "index_appointments_on_status"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "doctors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "experience_years", default: 0
    t.string "license_number"
    t.string "qualifications"
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.string "specialization", null: false
    t.integer "total_reviews", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_doctors_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "appointment_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "doctor_id", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["appointment_id"], name: "index_reviews_on_appointment_id"
    t.index ["doctor_id", "user_id"], name: "index_reviews_on_doctor_id_and_user_id"
    t.index ["doctor_id"], name: "index_reviews_on_doctor_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.string "reset_token"
    t.datetime "reset_token_sent_at"
    t.string "role", default: "client", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_token"], name: "index_users_on_reset_token", unique: true
  end

  add_foreign_key "appointments", "doctors"
  add_foreign_key "appointments", "users"
  add_foreign_key "doctors", "users"
  add_foreign_key "reviews", "appointments"
  add_foreign_key "reviews", "doctors"
  add_foreign_key "reviews", "users"
end

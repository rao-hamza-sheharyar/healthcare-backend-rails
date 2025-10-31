# This file should ensure the presence of all required library files
# required to run this application. The libraries are ensured to have been
# available when `rails generate` was run.

# Create an admin user
admin = User.find_or_initialize_by(email: 'admin@healthcare.com')
if admin.new_record?
  admin.assign_attributes(
    first_name: 'Admin',
    last_name: 'User',
    password: 'admin123',
    role: 'admin'
  )
  admin.save!
  puts "Admin user created: #{admin.email} / admin123"
else
  puts "Admin user already exists: #{admin.email}"
end

# Create sample doctor
doctor_user = User.find_or_initialize_by(email: 'doctor@healthcare.com')
if doctor_user.new_record?
  doctor_user.assign_attributes(
    first_name: 'John',
    last_name: 'Smith',
    password: 'doctor123',
    role: 'doctor'
  )
  doctor_user.save!
  
  doctor = Doctor.create!(
    user: doctor_user,
    specialization: 'Cardiologist',
    description: 'Experienced cardiologist with over 15 years of practice.',
    qualifications: 'MD, FACC',
    experience_years: 15,
    license_number: 'DOC-12345'
  )
  puts "Sample doctor created: #{doctor_user.email} / doctor123"
else
  puts "Doctor user already exists: #{doctor_user.email}"
end

# Create sample patient
patient = User.find_or_initialize_by(email: 'patient@healthcare.com')
if patient.new_record?
  patient.assign_attributes(
    first_name: 'Jane',
    last_name: 'Doe',
    password: 'patient123',
    role: 'patient',
    phone: '+1234567890',
    address: '123 Main St, City, State'
  )
  patient.save!
  puts "Sample patient created: #{patient.email} / patient123"
else
  puts "Patient user already exists: #{patient.email}"
end

class UserMailer < ApplicationMailer
  def welcome_email(user, password)
    @user = user
    @password = password
    mail(
      to: @user.email,
      subject: 'Welcome to Healthcare Portal - Your Login Credentials'
    )
  end

  def password_reset_email(user, reset_token)
    @user = user
    @reset_token = reset_token
    @reset_url = "#{ENV['FRONTEND_URL'] || 'http://localhost:5173'}/reset-password?token=#{reset_token}"
    mail(
      to: @user.email,
      subject: 'Password Reset Request - Healthcare Portal'
    )
  end

  def appointment_confirmation(appointment)
    @appointment = appointment
    @user = appointment.user
    @doctor = appointment.doctor
    mail(
      to: @user.email,
      subject: "Appointment Confirmed with Dr. #{@doctor.user.full_name}"
    )
  end

  def appointment_status_update(appointment)
    @appointment = appointment
    @user = appointment.user
    @doctor = appointment.doctor
    mail(
      to: @user.email,
      subject: "Appointment #{appointment.status.capitalize} - Healthcare Portal"
    )
  end

  def appointment_rescheduled(appointment, old_date)
    @appointment = appointment
    @user = appointment.user
    @doctor = appointment.doctor
    @old_date = old_date
    mail(
      to: @user.email,
      subject: "Appointment Rescheduled - Healthcare Portal"
    )
  end

  def reschedule_requested(appointment)
    @appointment = appointment
    @user = appointment.user
    @doctor = appointment.doctor
    mail(
      to: @doctor.user.email,
      subject: "Reschedule Request from #{@user.full_name} - Healthcare Portal"
    )
  end

  def reschedule_approved(appointment, old_date)
    @appointment = appointment
    @user = appointment.user
    @doctor = appointment.doctor
    @old_date = old_date
    mail(
      to: @user.email,
      subject: "Reschedule Request Approved - Healthcare Portal"
    )
  end

  def reschedule_rejected(appointment)
    @appointment = appointment
    @user = appointment.user
    @doctor = appointment.doctor
    mail(
      to: @user.email,
      subject: "Reschedule Request - Healthcare Portal"
    )
  end
end


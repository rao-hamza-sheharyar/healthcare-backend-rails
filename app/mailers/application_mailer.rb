class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILER_FROM'] || "noreply@healthcare-portal.com"
  layout "mailer"
end

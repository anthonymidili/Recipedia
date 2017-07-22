# Load the Rails application.
require_relative 'application'

# SMTP Mailer
ActionMailer::Base.smtp_settings = {
  user_name:           ENV["SENDGRID_USERNAME"],
  password:            ENV["SENDGRID_PASSWORD"],
  address:             ENV['SENDGRID_ADDRESS'],
  domain:              ENV['SMTP_DOMAIN'],
  port:                ENV['SMTP_PORT'],
  authentication:      ENV['SMTP_AUTHENTICATION'],
  openssl_verify_mode: ENV['SMTP_OPENSSL_VERIFY_MODE'],
  enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO']
}

# Initialize the Rails application.
Rails.application.initialize!

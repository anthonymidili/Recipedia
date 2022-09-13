Rails.application.configure do
  # Devise mailer
  config.action_mailer.default_url_options = {
    host: ENV.fetch('DEFAULT_URL') { 'localhost:3000' }
  }

  # Mailgun SMTP Mailer
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    address:              ENV['SMTP_ADDRESS'],
    domain:               ENV['SMTP_DOMAIN'],
    port:                 ENV['SMTP_PORT'],
    authentication:       ENV['SMTP_AUTHENTICATION'],
    openssl_verify_mode:  ENV['SMTP_OPENSSL_VERIFY_MODE'],
    enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO']
  }
end

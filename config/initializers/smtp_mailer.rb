Rails.application.configure do
  # Devise mailer
  # config.action_mailer.default_url_options = {
  #   host: ENV.fetch("DEFAULT_URL") { "localhost:3000" }
  # }

  # SMTP Mailer
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name:            Rails.application.credentials.dig(:smtp, :username),
    password:             Rails.application.credentials.dig(:smtp, :password),
    address:              Rails.application.credentials.dig(:smtp, :address),
    domain:               Rails.application.credentials.dig(:smtp, :domain),
    port:                 Rails.application.credentials.dig(:smtp, :port),
    authentication:       Rails.application.credentials.dig(:smtp, :authentication),
    openssl_verify_mode:  Rails.application.credentials.dig(:smtp, :openssl_verify_mode),
    enable_starttls_auto: Rails.application.credentials.dig(:smtp, :enable_starttls_auto)
  }
end

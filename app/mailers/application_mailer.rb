class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_SENDER') { 'to@example.org' }
  layout 'mailer'
end

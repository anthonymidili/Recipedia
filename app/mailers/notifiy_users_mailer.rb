class NotifiyUsersMailer < ApplicationMailer
  # requires 'notifications_helper' and includes NotificationsHelper
  helper :notifications

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifiy_users_mailer.activity.subject
  #
  def activity(notifiable, notifier, recipients_email, action_statement)
    @notifiable = notifiable
    @notifier = notifier
    @recipients_email = recipients_email
    @action_statement = action_statement

    mail bcc: @recipients_email,
    subject: "#{@notifier.username} #{@action_statement}"
  end
end

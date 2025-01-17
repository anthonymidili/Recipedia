# Preview all emails at http://localhost:3000/rails/mailers/notifiy_users_mailer
class NotifiyUsersMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notifiy_users_mailer/notifiable
  def notifiable
    NotifiyUsersMailer.notifiable
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifiy_users_mailer/notifier
  def notifier
    NotifiyUsersMailer.notifier
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifiy_users_mailer/recipients
  def recipients
    NotifiyUsersMailer.recipients
  end
end

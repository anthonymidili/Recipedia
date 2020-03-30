class NotifyFollowers
  def self.after_commit(notifiable)
    if notifiable.published
      recipients = notifiable.user.followers.by_unnotified(notifiable)
      create_notifications(notifiable, recipients)
      # future mail_notifications(notifiable, recipients)
    end
  end

private

  def self.create_notifications(notifiable, recipients)
    recipients.each do |recipient|
      if notifiable.published
        NotifiyUserJob.perform_later(notifiable, recipient, action_statement(notifiable))
      end
    end
  end

  # def self.mail_notifications(notifiable, recipients)
  #   # bulk mail
  # end

  def self.action_statement(notifiable)
    case notifiable.class.name
    when 'Recipe'
      'added a new recipe'
    end
  end
end

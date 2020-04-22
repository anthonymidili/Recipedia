class NotifyUsers
  class << self
    def after_commit(notifiable)
      recipients = recipients(notifiable)
      if recipients.any?
        mail_notifications(notifiable, recipients)
        create_notifications(notifiable, recipients)
      end
      CleanupNotificationsJob.perform_later
    end

  private

    def recipients(notifiable)
      case notifiable.class.name
      when 'Recipe'
        notifiable.user.followers.by_unnotified(notifiable) if notifiable.published
      when 'RecipeImage'
        User.by_uploaders(notifiable)
      when 'Review'
        User.by_reviewers(notifiable)
      when 'Relationship'
        User.where(id: notifiable.followed)
      when 'Favoritism'
        User.where(id: notifiable.recipe.user)
      end
    end

    def mail_notifications(notifiable, recipients)
      recipients_email = recipients.recipients_email(notifiable)
      if recipients_email.any?
        NotifiyUsersMailer.activity(notifiable, notifiable.user,
          recipients_email, action_statement(notifiable)).deliver_later
      end
    end

    def create_notifications(notifiable, recipients)
      recipients.each do |recipient|
        NotifiyUserJob.perform_later(notifiable, recipient, action_statement(notifiable))
      end
    end

    def action_statement(notifiable)
      case notifiable.class.name
      when 'Recipe'
        "ADDED a new recipe - #{notifiable.name}"
      when 'RecipeImage'
        "UPLOADED an image to recipe #{notifiable.recipe.name}"
      when 'Review'
        "REVIEWED recipe #{notifiable.recipe.name}"
      when 'Relationship'
        "started FOLLOWING you"
      when 'Favoritism'
        "ADDED #{notifiable.recipe.name} to their favorites"
      end
    end
  end
end

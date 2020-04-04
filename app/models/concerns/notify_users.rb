class NotifyUsers
  class << self
    def after_commit(notifiable)
      recipients = recipients(notifiable)
      create_notifications(notifiable, recipients)
      mail_notifications(notifiable, recipients)
    end

  private

    def create_notifications(notifiable, recipients)
      recipients.each do |recipient|
        NotifiyUserJob.perform_later(notifiable, recipient, action_statement(notifiable))
      end
    end

    def mail_notifications(notifiable, recipients)
      if recipients.any?
        NotifiyUsersMailer.activity(notifiable, notifiable.user, recipients.pluck(:email),
          action_statement(notifiable)).deliver_later
      end
    end

    def recipients(notifiable)
      case notifiable.class.name
      when 'Recipe'
        notifiable.user.followers.by_unnotified(notifiable)
      when 'Review'
        recipients = notifiable.recipe.reviews.map(&:user)
        recipients << notifiable.recipe.user
        (recipients - [notifiable.user]).uniq
      when 'Relationship'
        [notifiable.followed]
      when 'Favoritism'
        [notifiable.recipe.user]
      end
    end

    def action_statement(notifiable)
      case notifiable.class.name
      when 'Recipe'
        "ADDED a new recipe - #{notifiable.name}"
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

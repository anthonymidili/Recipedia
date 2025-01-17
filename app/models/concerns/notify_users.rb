class NotifyUsers
  def initialize(notifiable)
    recipients = recipients(notifiable)
    if recipients.any?
      mail_notifications(notifiable, recipients)
      create_notifications(notifiable, recipients)
    end
  end

private

  def recipients(notifiable)
    case notifiable.class.name
    when "Recipe"
      notifiable.user.followers.by_unnotified(notifiable) if notifiable.published
    when "RecipeImage"
      User.by_uploaders(notifiable)
    when "Review"
      User.by_reviewers(notifiable)
    when "Relationship"
      User.where(id: notifiable.followed)
    when "Favoritism"
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
      notification =
        notifiable.notifications.create(
          notifier: notifiable.user,
          recipient: recipient,
          action: action_statement(notifiable)
        )

      NotifyUserChannel.broadcast_to recipient,
      unread_notifications_count: recipient.notifications.unread_count,
      notification_partial: render_notification(notification)
    end
  end

  def render_notification(notification)
    renderer = ApplicationController.renderer.new(
      http_host: ENV.fetch("DEFAULT_URL", "localhost:3000"),
      https: false
    )

    renderer.render partial: "notifications/notification",
    locals: { notification: notification }
  end

  def action_statement(notifiable)
    case notifiable.class.name
    when "Recipe"
      "ADDED a new recipe - #{notifiable.name}"
    when "RecipeImage"
      "UPLOADED an image to recipe #{notifiable.recipe.name}"
    when "Review"
      "REVIEWED recipe #{notifiable.recipe.name}"
    when "Relationship"
      "started FOLLOWING you"
    when "Favoritism"
      "ADDED #{notifiable.recipe.name} to their favorites"
    end
  end
end

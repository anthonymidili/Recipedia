class PushNotificationService
  def self.send_notification(user, notification)
    # Queue push notification as a background job
    SendPushNotificationJob.perform_later(user.id, notification.id)
  end

  def self.send_notification_now(user, notification)
    # For immediate sending (testing purposes)
    service = new
    return unless user.push_subscriptions.any?

    message = service.send(:build_message, notification)

    user.push_subscriptions.each do |subscription|
      service.send(:send_to_subscription, subscription, message)
    end
  end

  private

  def send_to_subscription(subscription, message)
    WebPush.payload_send(
      message: message.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: vapid_details,
      ssl_timeout: 10,
      open_timeout: 10,
      read_timeout: 10
    )
  rescue WebPush::Unauthorized, WebPush::ExpiredSubscription => e
    Rails.logger.warn "Push subscription expired or unauthorized: #{e.message}"
    subscription.destroy
  rescue WebPush::InvalidSubscription => e
    Rails.logger.warn "Invalid push subscription: #{e.message}"
    subscription.destroy
  rescue => e
    Rails.logger.error "Push notification error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
  end

  def build_message(notification)
    {
      title: "Recipedia",
      body: notification_body(notification),
      icon: icon_url,
      badge: badge_url,
      data: {
        url: notification_url(notification),
        notification_id: notification.id
      },
      actions: [
        { action: "view", title: "View" },
        { action: "close", title: "Dismiss" }
      ]
    }
  end

  def notification_body(notification)
    case notification.notifiable_type
    when "Recipe"
      "#{notification.notifier.username} #{notification.action}"
    when "RecipeImage"
      "#{notification.notifier.username} #{notification.action}"
    when "Review"
      "#{notification.notifier.username} #{notification.action}"
    when "Relationship"
      "#{notification.notifier.username} started following you"
    when "Favoritism"
      "#{notification.notifier.username} favorited your recipe"
    else
      notification.action
    end
  end

  def notification_url(notification)
    base_url = ENV.fetch("DEFAULT_URL", "http://localhost:3000")
    case notification.notifiable_type
    when "Recipe"
      recipe = notification.notifiable
      "#{base_url}/recipes/#{recipe.user.username}/#{recipe.slug}"
    when "RecipeImage", "Review"
      recipe = notification.notifiable.recipe
      "#{base_url}/recipes/#{recipe.user.username}/#{recipe.slug}"
    when "Relationship"
      user = notification.notifier
      "#{base_url}/users/#{user.id}"
    when "Favoritism"
      recipe = notification.notifiable.recipe
      "#{base_url}/recipes/#{recipe.user.username}/#{recipe.slug}"
    else
      "#{base_url}/notifications"
    end
  end

  def icon_url
    base_url = ENV.fetch("DEFAULT_URL", "http://localhost:3000")
    "#{base_url}/favicon.svg"
  end

  def badge_url
    base_url = ENV.fetch("DEFAULT_URL", "http://localhost:3000")
    "#{base_url}/favicon.svg"
  end

  def vapid_details
    {
      subject: "mailto:#{ENV.fetch('NOTIFICATION_EMAIL', 'notifications@recipedia.com')}",
      public_key: Rails.application.credentials.dig(:web_push, :vapid_public_key),
      private_key: Rails.application.credentials.dig(:web_push, :vapid_private_key)
    }
  end
end

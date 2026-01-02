class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, notification_id)
    user = User.find_by(id: user_id)
    notification = Notification.find_by(id: notification_id)

    return unless user && notification

    # Send push notification immediately in background
    PushNotificationService.send_notification_now(user, notification)
  end
end

class SendActionCableNotificationJob < ApplicationJob
  queue_as :default

  def perform(recipient_id, notification_id)
    recipient = User.find_by(id: recipient_id)
    notification = Notification.find_by(id: notification_id)

    return unless recipient && notification

    # Send real-time notification via Action Cable
    NotifyUserChannel.broadcast_to recipient,
      unread_notifications_count: recipient.notifications.unread_count,
      notification_partial: ApplicationController.render(
        partial: "notifications/notification",
        locals: { notification: notification }
      )
  end
end

class NotifiyUserJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(notifiable, recipient, action)
    notifiable.notifications.create(
      notifier: notifiable.user,
      recipient: recipient,
      action: action
    )

    NotifyUserChannel.broadcast_to recipient,
    unread_notifications_count: recipient.notifications.by_unread.count
  end
end

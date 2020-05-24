class MarkNotificationsAsReadJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(current_user)
    current_user.notifications.by_unread.mark_as_read

    NotifyUserChannel.broadcast_to current_user,
    unread_notifications_count: current_user.notifications.unread_count,
    clear_notifications: true
  end
end

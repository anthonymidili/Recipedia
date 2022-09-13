class MarkNotificationsAsReadJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(user)
    # Mark notifications as read and broadcast to
    # current user updated notification bell.
    user.mark_as_read
  end
end

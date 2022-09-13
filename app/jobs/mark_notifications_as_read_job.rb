class MarkNotificationsAsReadJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(user_id)
    user = User.find_by(id: user_id)

    # Mark notifications as read and broadcast to
    # current user updated notification bell.
    user.mark_as_read
  end
end

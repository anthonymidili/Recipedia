require "test_helper"

class MarkNotificationsAsReadJobTest < ActiveJob::TestCase
  test "marks a user's notifications as read" do
    user = users(:one)

    create(:notification, recipient: user, is_read: false)
    create(:notification, recipient: user, is_read: false)

    assert_equal 2, user.notifications.unread_count

    MarkNotificationsAsReadJob.perform_now(user)

    assert_equal 0, user.notifications.unread_count
  end
end

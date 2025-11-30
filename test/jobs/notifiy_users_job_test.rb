require "test_helper"

class NotifiyUsersJobTest < ActiveJob::TestCase
  test "creates notification for followed user when relationship is created" do
    # Build a relationship (user :one follows user :two)
    user = users(:one)
    followed = users(:two)

    # Clear any existing notifications
    Notification.delete_all

    relationship = Relationship.create!(user: user, followed: followed)

    # Perform the job
    assert_difference "Notification.count", 1 do
      NotifiyUsersJob.perform_now(relationship)
    end

    # Verify the notification was created for the followed user
    notification = Notification.last
    assert_equal followed, notification.recipient
    assert_equal user, notification.notifier
    assert_equal relationship, notification.notifiable
  end
end

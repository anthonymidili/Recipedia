require "test_helper"

class SendActionCableNotificationJobTest < ActiveJob::TestCase
  def setup
    @user = create(:user)
    @recipe = create(:recipe, user: @user)
  end

  test "broadcasts notification to user channel" do
    notification = create(:notification, recipient: @user, action: "followed")

    assert_broadcasts(NotifyUserChannel.broadcasting_for(@user), 1) do
      SendActionCableNotificationJob.perform_now(@user.id, notification.id)
    end
  end

  test "includes unread count in broadcast" do
    notification = create(:notification, recipient: @user, action: "followed")

    assert_broadcasts(NotifyUserChannel.broadcasting_for(@user), 1) do
      SendActionCableNotificationJob.perform_now(@user.id, notification.id)
    end
  end

  test "handles missing user gracefully" do
    notification = create(:notification, recipient: @user, action: "followed")

    assert_no_broadcasts(NotifyUserChannel.broadcasting_for(@user)) do
      SendActionCableNotificationJob.perform_now(99999, notification.id)
    end
  end

  test "handles missing notification gracefully" do
    assert_no_broadcasts(NotifyUserChannel.broadcasting_for(@user)) do
      SendActionCableNotificationJob.perform_now(@user.id, 99999)
    end
  end

  test "uses default queue" do
    assert_equal "default", SendActionCableNotificationJob.new.queue_name
  end
end

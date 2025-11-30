require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @notification = notifications(:one)
  end

  test "should require authentication for index" do
    get notifications_url
    assert_redirected_to new_user_session_path
  end

  test "should get index when authenticated" do
    sign_in(@user)
    get notifications_url
    assert_response :success
  end

  test "should mark notifications as read when authenticated" do
    sign_in(@user)
    patch mark_as_read_notifications_url
    assert_response :success
  end

  test "should get settings when authenticated" do
    sign_in(@user)
    get settings_notifications_url
    assert_response :success
  end

  test "should update settings when authenticated" do
    sign_in(@user)
    # Ensure notification_setting exists
    @user.create_notification_setting! unless @user.notification_setting
    patch update_settings_notifications_url, params: {
      notification_setting: { receive_email: false }
    }
    assert_redirected_to notifications_path
  end
end

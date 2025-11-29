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
    patch notifications_mark_as_read_url
    assert_response :success
  end

  test "should get settings when authenticated" do
    sign_in(@user)
    get notifications_settings_url
    assert_response :success
  end

  test "should update settings when authenticated" do
    sign_in(@user)
    patch notifications_update_settings_url, params: {
      notification_setting: { receive_email: false }
    }
    assert_response :success
  end
end

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get show" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit when own profile" do
    sign_in(@user)
    get edit_user_url(@user)
    assert_response :success
  end

  test "should not allow edit of other profile" do
    sign_in(@user)
    get edit_user_url(@other_user)
    assert_response :forbidden
  end

  test "should update own profile" do
    sign_in(@user)
    patch user_url(@user), params: {
      user: { username: "new_username" }
    }
    assert_redirected_to user_url(@user)
  end

  test "should get followers for user" do
    get user_url(@user, action: :followers)
    assert_response :success
  end

  test "should get following for user" do
    get user_url(@user, action: :following)
    assert_response :success
  end

  test "should destroy user when own account" do
    sign_in(@user)
    user_id = @user.id
    delete user_url(@user)
    assert_not User.exists?(user_id)
  end

  test "should not allow destroy of other account" do
    sign_in(@user)
    other_user_id = @other_user.id
    delete user_url(@other_user)
    assert User.exists?(other_user_id)
  end
end

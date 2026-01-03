require "test_helper"

class UserModelSecurityTest < ActiveSupport::TestCase
  test "user has before_destroy callback" do
    user = create_user
    callbacks = User._destroy_callbacks.map(&:filter)
    assert_includes callbacks, :reassign_content_to_admin
  end

  test "user slug is set before save" do
    user = User.new(
      username: "test_user",
      email: "test@example.com",
      password: "password123"
    )

    assert_nil user.slug
    user.save!
    assert_equal "test_user", user.slug
  end

  test "user slug is updated when username changes" do
    user = create_user(username: "original_name")
    assert_equal "original_name", user.slug

    user.update!(username: "new_name")
    assert_equal "new_name", user.slug
  end

  test "to_param returns slug" do
    user = create_user(username: "my_username")
    assert_equal "my_username", user.to_param
  end

  test "cannot create user with duplicate username" do
    create_user(username: "duplicate_user")

    duplicate = User.new(
      username: "duplicate_user",
      email: "different@example.com",
      password: "password123"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:username], "has already been taken"
  end

  test "username is required" do
    user = User.new(email: "test@example.com", password: "password123")

    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end
end

require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "creates valid push subscription" do
    subscription = @user.push_subscriptions.build(
      endpoint: "https://fcm.googleapis.com/fcm/send/test123",
      p256dh_key: "test_p256dh_key",
      auth_key: "test_auth_key"
    )

    assert subscription.valid?
    assert subscription.save
  end

  test "requires endpoint" do
    subscription = @user.push_subscriptions.build(
      p256dh_key: "test_key",
      auth_key: "test_auth"
    )

    assert_not subscription.valid?
    assert_includes subscription.errors[:endpoint], "can't be blank"
  end

  test "requires p256dh_key" do
    subscription = @user.push_subscriptions.build(
      endpoint: "https://example.com/push",
      auth_key: "test_auth"
    )

    assert_not subscription.valid?
    assert_includes subscription.errors[:p256dh_key], "can't be blank"
  end

  test "requires auth_key" do
    subscription = @user.push_subscriptions.build(
      endpoint: "https://example.com/push",
      p256dh_key: "test_key"
    )

    assert_not subscription.valid?
    assert_includes subscription.errors[:auth_key], "can't be blank"
  end

  test "endpoint must be unique" do
    @user.push_subscriptions.create!(
      endpoint: "https://example.com/push/unique",
      p256dh_key: "test_key",
      auth_key: "test_auth"
    )

    duplicate = @user.push_subscriptions.build(
      endpoint: "https://example.com/push/unique",
      p256dh_key: "different_key",
      auth_key: "different_auth"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:endpoint], "has already been taken"
  end

  test "belongs to user" do
    subscription = @user.push_subscriptions.create!(
      endpoint: "https://example.com/push",
      p256dh_key: "test_key",
      auth_key: "test_auth"
    )

    assert_equal @user, subscription.user
  end

  test "destroying user destroys subscriptions" do
    @user.push_subscriptions.create!(
      endpoint: "https://example.com/push",
      p256dh_key: "test_key",
      auth_key: "test_auth"
    )

    assert_difference "PushSubscription.count", -1 do
      @user.destroy
    end
  end
end

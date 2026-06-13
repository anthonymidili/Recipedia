require "test_helper"

class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
  end

  test "unauthenticated user cannot manage push subscriptions" do
    post push_subscriptions_path, params: {
      subscription: {
        endpoint: "https://example.com/endpoint",
        keys: { p256dh: "key", auth: "auth" }
      }
    }
    assert_redirected_to new_user_session_path

    delete push_subscription_path(1), params: { endpoint: "https://example.com/endpoint" }
    assert_redirected_to new_user_session_path
  end

  test "authenticated user can create a push subscription" do
    sign_in(@user)
    assert_difference "PushSubscription.count", 1 do
      post push_subscriptions_path, params: {
        subscription: {
          endpoint: "https://example.com/endpoint",
          keys: { p256dh: "key", auth: "auth" }
        }
      }, as: :json
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal "Push notifications enabled!", json_response["message"]
  end

  test "returns error when creating invalid push subscription" do
    sign_in(@user)
    assert_no_difference "PushSubscription.count" do
      post push_subscriptions_path, params: {
        subscription: {
          endpoint: "",
          keys: { p256dh: "", auth: "" }
        }
      }, as: :json
    end
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  test "authenticated user can destroy their own push subscription" do
    sign_in(@user)
    subscription = @user.push_subscriptions.create!(
      endpoint: "https://example.com/endpoint",
      p256dh_key: "key",
      auth_key: "auth"
    )

    assert_difference "PushSubscription.count", -1 do
      delete push_subscription_path(subscription), params: { endpoint: "https://example.com/endpoint" }, as: :json
    end
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal "Push notifications disabled", json_response["message"]
  end

  test "returns error when destroying non-existent subscription" do
    sign_in(@user)
    delete push_subscription_path(999), params: { endpoint: "https://example.com/non-existent" }, as: :json
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
    assert_equal "Subscription not found", json_response["message"]
  end

  test "vapid_public_key action returns public key" do
    sign_in(@user)
    get vapid_public_key_push_subscriptions_path
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?("publicKey")
  end
end

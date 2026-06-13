require "test_helper"

class PushNotificationServiceTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @recipe = create_recipe
    @notification = Notification.create!(
      notifier: @recipe.user,
      recipient: @user,
      notifiable: @recipe,
      action: "published a new recipe"
    )
  end

  # Custom helper to stub class/module methods without minitest-mock
  def stub_class_method(object, method_name, stubbed_impl)
    original_method = object.method(method_name) rescue nil
    object.define_singleton_method(method_name, &stubbed_impl)
    begin
      yield
    ensure
      if original_method
        object.define_singleton_method(method_name, &original_method)
      else
        object.singleton_class.send(:remove_method, method_name) rescue nil
      end
    end
  end

  test "send_notification queues SendPushNotificationJob" do
    assert_enqueued_with(job: SendPushNotificationJob, args: [@user.id, @notification.id]) do
      PushNotificationService.send_notification(@user, @notification)
    end
  end

  test "send_notification_now does nothing if user has no subscriptions" do
    assert_empty @user.push_subscriptions

    stub_class_method(WebPush, :payload_send, ->(*) { flunk "WebPush should not have been called" }) do
      PushNotificationService.send_notification_now(@user, @notification)
    end
  end

  test "send_notification_now sends WebPush payload when user has subscription" do
    subscription = @user.push_subscriptions.create!(
      endpoint: "https://example.com/endpoint",
      p256dh_key: "p256dh",
      auth_key: "auth"
    )

    payload_called = false
    passed_args = nil

    payload_stub = lambda do |args|
      payload_called = true
      passed_args = args
      true
    end

    stub_class_method(WebPush, :payload_send, payload_stub) do
      PushNotificationService.send_notification_now(@user, @notification)
    end

    assert payload_called
    assert_equal "https://example.com/endpoint", passed_args[:endpoint]
    assert_equal "p256dh", passed_args[:p256dh]
    assert_equal "auth", passed_args[:auth]

    message = JSON.parse(passed_args[:message])
    assert_equal "Recipedia", message["title"]
    assert_includes message["body"], "published a new recipe"
  end

  test "destroys subscription if subscription is unauthorized or expired" do
    subscription = @user.push_subscriptions.create!(
      endpoint: "https://example.com/endpoint",
      p256dh_key: "p256dh",
      auth_key: "auth"
    )

    response = Struct.new(:body).new("unauthorized")
    stub_class_method(WebPush, :payload_send, ->(*) { raise WebPush::Unauthorized.new(response, "example.com") }) do
      assert_difference "PushSubscription.count", -1 do
        PushNotificationService.send_notification_now(@user, @notification)
      end
    end
  end
end

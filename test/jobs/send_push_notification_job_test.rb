require "test_helper"

class SendPushNotificationJobTest < ActiveJob::TestCase
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

  test "performs push notification delivery" do
    called_user = nil
    called_notification = nil

    service_stub = lambda do |user, notification|
      called_user = user
      called_notification = notification
      true
    end

    stub_class_method(PushNotificationService, :send_notification_now, service_stub) do
      SendPushNotificationJob.perform_now(@user.id, @notification.id)
    end

    assert_equal @user, called_user
    assert_equal @notification, called_notification
  end

  test "aborts early if user or notification not found" do
    stub_class_method(PushNotificationService, :send_notification_now, ->(*) { flunk "Should not have been called" }) do
      assert_nil SendPushNotificationJob.perform_now(nil, @notification.id)
      assert_nil SendPushNotificationJob.perform_now(@user.id, nil)
    end
  end
end

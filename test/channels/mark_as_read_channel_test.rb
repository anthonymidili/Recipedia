require File.expand_path("../test_helper", __dir__)

class MarkAsReadChannelTest < ActionCable::Channel::TestCase
  setup do
    @user = users(:one)
  end

  test "subscribes and streams for current user" do
    stub_connection current_user: @user

    subscribe

    assert subscription.confirmed?
    assert_has_stream_for @user
  end

  test "unsubscribes and stops all streams" do
    stub_connection current_user: @user

    subscribe
    assert subscription.confirmed?

    unsubscribe

    assert_no_streams
  end

  test "broadcasts unread notifications count to subscribed user" do
    stub_connection current_user: @user

    subscribe

    assert_broadcast_on(@user, unread_notifications_count: 0) do
      MarkAsReadChannel.broadcast_to(@user, unread_notifications_count: 0)
    end
  end
end

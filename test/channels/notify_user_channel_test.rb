require "test_helper"

class NotifyUserChannelTest < ActionCable::Channel::TestCase
  setup do
    @user = users(:one)
    stub_connection current_user: @user
  end

  test "subscribes" do
    subscribe
    assert subscription.confirmed?
  end
end

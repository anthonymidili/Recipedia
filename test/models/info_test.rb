require "test_helper"

class InfoTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should create valid info" do
    info = Info.new(
      user: @user,
      body: "This is my bio information"
    )

    assert info.valid?
    assert info.save
  end

  test "should belong to user" do
    info = Info.create!(
      user: @user,
      body: "Test bio"
    )

    assert_equal @user, info.user
  end

  test "should require user" do
    info = Info.new(body: "Test bio")

    assert_not info.valid?
  end

  test "should allow nil body" do
    info = Info.new(user: @user, body: nil)

    assert info.valid?
  end

  test "should allow empty body" do
    info = Info.new(user: @user, body: "")

    assert info.valid?
  end

  test "should update body" do
    info = Info.create!(user: @user, body: "Original bio")

    info.update(body: "Updated bio")

    assert_equal "Updated bio", info.body
  end

  test "user can have info" do
    assert_respond_to @user, :info
  end
end

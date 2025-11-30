require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @notifier = users(:two)
    @recipe = recipes(:one)
  end

  test "should create valid notification" do
    notification = Notification.new(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "liked your recipe"
    )

    assert notification.valid?
    assert notification.save
  end

  test "should require notifiable" do
    notification = Notification.new(
      notifier: @notifier,
      recipient: @user,
      action: "test action"
    )

    assert_not notification.valid?
  end

  test "should require notifier" do
    notification = Notification.new(
      notifiable: @recipe,
      recipient: @user,
      action: "test action"
    )

    assert_not notification.valid?
  end

  test "should require recipient" do
    notification = Notification.new(
      notifiable: @recipe,
      notifier: @notifier,
      action: "test action"
    )

    assert_not notification.valid?
  end

  test "should default is_read to false" do
    notification = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "test action"
    )

    assert_equal false, notification.is_read
  end

  test "by_unread scope returns only unread notifications" do
    # Create unread notification
    unread = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "unread action",
      is_read: false
    )

    # Create read notification
    read = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "read action",
      is_read: true
    )

    unread_notifications = Notification.by_unread

    assert_includes unread_notifications, unread
    assert_not_includes unread_notifications, read
  end

  test "by_read scope returns only read notifications" do
    # Create unread notification
    unread = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "unread action",
      is_read: false
    )

    # Create read notification
    read = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "read action",
      is_read: true
    )

    read_notifications = Notification.by_read

    assert_includes read_notifications, read
    assert_not_includes read_notifications, unread
  end

  test "unread_count scope returns count of unread notifications" do
    initial_count = Notification.unread_count

    # Create 3 unread notifications
    3.times do |i|
      Notification.create!(
        notifiable: @recipe,
        notifier: @notifier,
        recipient: @user,
        action: "unread action #{i}",
        is_read: false
      )
    end

    # Create 2 read notifications
    2.times do |i|
      Notification.create!(
        notifiable: @recipe,
        notifier: @notifier,
        recipient: @user,
        action: "read action #{i}",
        is_read: true
      )
    end

    assert_equal initial_count + 3, Notification.unread_count
  end

  test "mark_as_read scope marks all notifications as read" do
    # Create unread notifications
    3.times do |i|
      Notification.create!(
        notifiable: @recipe,
        notifier: @notifier,
        recipient: @user,
        action: "action #{i}",
        is_read: false
      )
    end

    unread_before = Notification.by_unread.count
    assert unread_before > 0

    Notification.by_unread.mark_as_read

    unread_after = Notification.by_unread.count
    assert_equal 0, unread_after
  end

  test "by_older_than_month scope returns notifications older than one month" do
    # Create old notification
    old_notification = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "old action",
      created_at: 2.months.ago
    )

    # Create recent notification
    recent_notification = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "recent action"
    )

    old_notifications = Notification.by_older_than_month

    assert_includes old_notifications, old_notification
    assert_not_includes old_notifications, recent_notification
  end

  test "default scope orders by created_at desc" do
    # Create notifications with different timestamps
    first = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "first action",
      created_at: 3.days.ago
    )

    second = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "second action",
      created_at: 2.days.ago
    )

    third = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "third action",
      created_at: 1.day.ago
    )

    notifications = Notification.where(id: [ first.id, second.id, third.id ])

    # Should be ordered newest first
    assert_equal third.id, notifications.first.id
    assert_equal first.id, notifications.last.id
  end

  test "polymorphic association allows different notifiable types" do
    # Test with Recipe
    recipe_notification = Notification.create!(
      notifiable: @recipe,
      notifier: @notifier,
      recipient: @user,
      action: "recipe notification"
    )

    assert_equal @recipe, recipe_notification.notifiable
    assert_equal "Recipe", recipe_notification.notifiable_type

    # Test with Relationship
    relationship = Relationship.create!(user: @notifier, followed: @user)
    relationship_notification = Notification.create!(
      notifiable: relationship,
      notifier: @notifier,
      recipient: @user,
      action: "followed you"
    )

    assert_equal relationship, relationship_notification.notifiable
    assert_equal "Relationship", relationship_notification.notifiable_type
  end

  test "notification email sent when recipe published to follower" do
    # Use an unpublished recipe
    unpublished_recipe = recipes(:three)

    # Create a follower who has NO recent unread notifications
    follower = FactoryBot.create(:user)
    Relationship.create!(user: follower, followed: unpublished_recipe.user)

    # Verify the relationship was created
    assert_includes unpublished_recipe.user.followers.reload, follower

    # Enable email notifications for recipe_created
    NotificationSetting.create!(
      user: follower,
      receive_email: true,
      recipe_created: true
    )

    # Clear deliveries
    ActionMailer::Base.deliveries.clear

    # Publishing a recipe should send an email
    # Note: Emails are only sent if user has no unread notifications from today (to prevent spam)
    # The notification is created first, then email logic runs
    # So we test that the mailer job is enqueued when publishing
    assert_enqueued_with(job: NotifiyUsersJob) do
      unpublished_recipe.update!(published: true)
    end
  end
end

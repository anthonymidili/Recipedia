require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should create user with valid attributes" do
    user = create_user
    assert user.persisted?
    assert_equal user.username, user.username
  end

  test "user requires username" do
    user = User.new(email: "test@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "user requires unique username" do
    create_user(username: "unique_user")
    user2 = User.new(username: "unique_user", email: "different@example.com", password: "password")
    assert_not user2.valid?
    assert_includes user2.errors[:username], "has already been taken"
  end

  test "user sets slug before save" do
    user = create_user(username: "test_user_123")
    assert_equal "test-user-123", user.slug
  end

  test "user to_param returns slug" do
    assert_equal @user.slug, @user.to_param
  end

  test "user has many recipes" do
    assert_equal 2, @user.recipes.count
  end

  test "user has many categories" do
    assert @user.has_many_through_association?(:categories)
  end

  test "user has many reviews" do
    user = create_user
    recipe = create_recipe(user)
    review = create_review(recipe, user)
    assert_includes user.reviews, review
  end

  test "user has many followers" do
    follower = users(:two)
    assert_includes @user.followers, follower
  end

  test "user has many following" do
    following = users(:two)
    assert_includes following.following, @user
  end

  test "following? returns true if following user" do
    follower = users(:two)
    assert follower.following?(@user)
  end

  test "following? returns false if not following user" do
    user1 = create_user
    user2 = create_user
    assert_not user1.following?(user2)
  end

  test "find_favoritism returns favoritism" do
    user = users(:one)
    recipe = recipes(:one)
    favoritism = Favoritism.create!(user: user, recipe: recipe)
    assert_equal favoritism, user.find_favoritism(recipe)
  end

  test "favorite_recipes returns all favorited recipes" do
    user = users(:one)
    recipe = recipes(:one)
    Favoritism.create!(user: user, recipe: recipe)
    assert_includes user.favorite_recipes, recipe
  end

  test "mark_as_read marks notifications as read" do
    user = create_user
    recipe = create_recipe
    notification = Notification.create!(
      user: recipe.user,
      recipient: user,
      notifiable: recipe
    )
    user.mark_as_read
    notification.reload
    assert notification.is_read?
  end

  test "user avatar can be attached" do
    user = users(:one)
    assert user.has_one_attached?(:avatar)
  end

  test "user has one notification setting" do
    user = users(:one)
    setting = user.notification_setting || user.create_notification_setting
    assert_equal setting.user_id, user.id
  end
end

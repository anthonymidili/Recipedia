require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = relationships(:one)
    @user = @relationship.user
    @followed = @relationship.followed
  end

  test "should create relationship with valid attributes" do
    user = users(:one)
    followed = users(:two)
    relationship = user.relationships.build(followed: followed)
    assert relationship.save
  end

  test "relationship belongs to user" do
    assert_equal @user, @relationship.user
  end

  test "relationship belongs to followed user" do
    assert_equal @followed, @relationship.followed
  end

  test "relationship validates presence of user" do
    relationship = Relationship.new(followed: @followed)
    assert_not relationship.valid?
  end

  test "relationship validates presence of followed" do
    relationship = Relationship.new(user: @user)
    assert_not relationship.valid?
  end

  test "can create multiple following relationships" do
    user = users(:one)
    follower1 = users(:two)
    follower2 = users(:three)

    rel1 = Relationship.create!(user: follower1, followed: user)
    rel2 = Relationship.create!(user: follower2, followed: user)

    assert_includes user.followers, follower1
    assert_includes user.followers, follower2
  end

  test "following and followers are different" do
    user = users(:one)
    follower = users(:two)

    assert_includes user.followers, follower
    assert_not_includes user.following, follower
    assert_includes follower.following, user
  end

  test "user can follow and be followed by same user" do
    user1 = users(:one)
    user2 = users(:two)

    Relationship.create!(user: user1, followed: user2)
    Relationship.create!(user: user2, followed: user1)

    assert_includes user1.following, user2
    assert_includes user1.followers, user2
  end
end

require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @relationship = relationships(:one)
  end

  test "should require authentication to create relationship" do
    assert_no_difference("Relationship.count") do
      post relationships_url, params: { followed_id: @other_user.id }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create relationship when authenticated" do
    sign_in(@user)
    assert_difference("Relationship.count") do
      post relationships_url, params: { followed_id: @other_user.id }
    end
  end

  test "should destroy relationship when authenticated" do
    sign_in(@user)
    relationship = Relationship.create!(user: @user, followed: @other_user)
    assert_difference("Relationship.count", -1) do
      delete relationship_url(relationship)
    end
  end

  test "should not allow destroying other user relationship" do
    sign_in(@other_user)
    followed_user = users(:three)
    relationship = Relationship.create!(user: @user, followed: followed_user)

    assert_no_difference("Relationship.count") do
      delete relationship_url(relationship)
    end
  end
end

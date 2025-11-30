require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @review = reviews(:one)
    @recipe = @review.recipe
    @user = @review.user
  end

  test "should get show" do
    get recipe_review_url(@recipe, @review)
    assert_response :success
  end

  test "should require auth to create review" do
    assert_no_difference("Review.count") do
      post recipe_reviews_url(@recipe), params: {
        review: { body: "<p>Great recipe!</p>" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create review when authenticated" do
    sign_in(@user)
    assert_difference("Review.count") do
      post recipe_reviews_url(@recipe), params: {
        review: { body: "<p>Great recipe!</p>" }
      }
    end
  end

  test "should get edit when own review" do
    sign_in(@user)
    get edit_recipe_review_url(@recipe, @review)
    assert_response :success
  end

  test "should not allow edit of other review" do
    other_user = users(:two)
    sign_in(other_user)
    get edit_recipe_review_url(@recipe, @review)
    assert_redirected_to root_path
  end

  test "should update review when owner" do
    sign_in(@user)
    patch recipe_review_url(@recipe, @review), params: {
      review: { body: "<p>Updated review</p>" }
    }
    assert_redirected_to recipe_url(@recipe, anchor: "review_#{@review.id}")
  end

  test "should destroy review when owner" do
    sign_in(@user)
    review_id = @review.id
    delete recipe_review_url(@recipe, @review)
    assert_not Review.exists?(review_id)
  end

  test "should not allow destroy of other review" do
    other_user = users(:two)
    sign_in(other_user)
    delete recipe_review_url(@recipe, @review)
    assert Review.exists?(@review.id)
  end
end

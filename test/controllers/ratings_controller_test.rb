require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = create_user
    @other_user = create_user
    @recipe = create_recipe(@author)
  end

  test "unauthenticated user cannot create a rating" do
    post user_recipe_ratings_path(@author.slug, @recipe.slug), params: { score: 5 }
    assert_redirected_to new_user_session_path
  end

  test "authenticated user can rate a recipe via turbo stream" do
    sign_in(@other_user)
    assert_difference "Rating.count", 1 do
      post user_recipe_ratings_path(@author.slug, @recipe.slug), params: { score: 5 }, as: :turbo_stream
    end
    assert_response :success
    assert_match /turbo-stream/, response.media_type
    assert_equal 5.0, @recipe.reload.average_rating
  end

  test "authenticated user can update their rating via turbo stream" do
    sign_in(@other_user)
    Rating.create!(user: @other_user, recipe: @recipe, score: 3)

    assert_no_difference "Rating.count" do
      post user_recipe_ratings_path(@author.slug, @recipe.slug), params: { score: 5 }, as: :turbo_stream
    end
    assert_response :success
    assert_match /turbo-stream/, response.media_type
    assert_equal 5.0, @recipe.reload.average_rating
  end

  test "author cannot rate their own recipe" do
    sign_in(@author)
    assert_no_difference "Rating.count" do
      post user_recipe_ratings_path(@author.slug, @recipe.slug), params: { score: 5 }
    end
    assert_redirected_to user_recipe_path(@author.slug, @recipe.slug)
    assert_equal 0.0, @recipe.reload.average_rating
  end

  test "invalid rating parameters do not save but redirect with alert" do
    sign_in(@other_user)
    assert_no_difference "Rating.count" do
      post user_recipe_ratings_path(@author.slug, @recipe.slug), params: { score: 10 }
    end
    assert_redirected_to user_recipe_path(@author.slug, @recipe.slug)
  end
end


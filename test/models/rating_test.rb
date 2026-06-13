require "test_helper"

class RatingTest < ActiveSupport::TestCase
  setup do
    @author = create_user
    @other_user = create_user
    @recipe = create_recipe(@author)
  end

  test "is valid with a valid score from a different user" do
    rating = Rating.new(user: @other_user, recipe: @recipe, score: 5)
    assert rating.valid?
  end

  test "is invalid without a score" do
    rating = Rating.new(user: @other_user, recipe: @recipe, score: nil)
    assert_not rating.valid?
    assert_includes rating.errors[:score], "can't be blank"
  end

  test "is invalid with an out-of-range score" do
    rating = Rating.new(user: @other_user, recipe: @recipe, score: 6)
    assert_not rating.valid?
    rating.score = 0
    assert_not rating.valid?
  end

  test "cannot rate the same recipe twice" do
    Rating.create!(user: @other_user, recipe: @recipe, score: 4)
    duplicate_rating = Rating.new(user: @other_user, recipe: @recipe, score: 5)
    assert_not duplicate_rating.valid?
    assert_includes duplicate_rating.errors[:user_id], "has already rated this recipe"
  end

  test "author cannot rate their own recipe" do
    rating = Rating.new(user: @author, recipe: @recipe, score: 5)
    assert_not rating.valid?
    assert_includes rating.errors[:base], "You cannot rate your own recipe"
  end

  test "updates recipe average rating and count after commit" do
    assert_equal 0.0, @recipe.reload.average_rating
    assert_equal 0, @recipe.reload.ratings_count

    Rating.create!(user: @other_user, recipe: @recipe, score: 4)
    assert_equal 4.0, @recipe.reload.average_rating
    assert_equal 1, @recipe.reload.ratings_count

    third_user = create_user
    Rating.create!(user: third_user, recipe: @recipe, score: 5)
    assert_equal 4.5, @recipe.reload.average_rating
    assert_equal 2, @recipe.reload.ratings_count
  end
end


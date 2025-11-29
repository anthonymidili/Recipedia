require "test_helper"

class FavoritismsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
  end

  test "should require authentication to create favoritism" do
    assert_no_difference("Favoritism.count") do
      post favoritisms_url, params: { recipe_id: @recipe.id }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create favoritism when authenticated" do
    sign_in(@user)
    assert_difference("Favoritism.count") do
      post favoritisms_url, params: { recipe_id: @recipe.id }
    end
  end

  test "should not create duplicate favoritism" do
    sign_in(@user)
    Favoritism.create!(user: @user, recipe: @recipe)

    assert_no_difference("Favoritism.count") do
      post favoritisms_url, params: { recipe_id: @recipe.id }
    end
  end

  test "should destroy favoritism when owner" do
    sign_in(@user)
    favoritism = Favoritism.create!(user: @user, recipe: @recipe)

    assert_difference("Favoritism.count", -1) do
      delete favoritism_url(favoritism)
    end
  end

  test "should not destroy other user favoritism" do
    other_user = users(:two)
    favoritism = Favoritism.create!(user: @user, recipe: @recipe)
    sign_in(other_user)

    assert_no_difference("Favoritism.count") do
      delete favoritism_url(favoritism)
    end
  end
end

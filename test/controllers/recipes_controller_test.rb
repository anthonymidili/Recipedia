require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @category = categories(:one)
  end

  test "should get index" do
    get recipes_url
    assert_response :success
    assert_select "h1"
  end

  test "should get index with pagination" do
    get recipes_url(page: 1)
    assert_response :success
  end

  test "should search recipes by name" do
    get recipes_url(search: "Pasta")
    assert_response :success
  end

  test "should get show" do
    get recipe_url(@recipe)
    assert_response :success
    assert_select "h1"
  end

  test "should get new when authenticated" do
    sign_in(@user)
    get new_recipe_url
    assert_response :success
  end

  test "should redirect to login when creating without authentication" do
    get new_recipe_url
    assert_redirected_to new_user_session_path
  end

  test "should create recipe when authenticated" do
    sign_in(@user)
    assert_difference("Recipe.count") do
      post recipes_url, params: {
        recipe: {
          name: "New Recipe",
          category_ids: [ @category.id ],
          parts_attributes: [ { name: "" } ]
        }
      }
    end
    assert_redirected_to recipe_url(Recipe.last)
  end

  test "should not create recipe without category" do
    sign_in(@user)
    assert_no_difference("Recipe.count") do
      post recipes_url, params: {
        recipe: { name: "No Category" }
      }
    end
  end

  test "should get edit when recipe owner" do
    sign_in(@user)
    get edit_recipe_url(@recipe)
    assert_response :success
  end

  test "should deny access to edit when not owner" do
    other_user = users(:two)
    sign_in(other_user)
    get edit_recipe_url(@recipe)
    assert_redirected_to root_path
  end

  test "should update recipe when owner" do
    sign_in(@user)
    new_name = "Updated Recipe Name"
    patch recipe_url(@recipe), params: {
      recipe: { name: new_name, category_ids: [ @category.id ] }
    }
    @recipe.reload
    assert_redirected_to recipe_url(@recipe)
    assert_equal new_name, @recipe.name
  end

  test "should destroy recipe when owner" do
    sign_in(@user)
    recipe_id = @recipe.id
    delete recipe_url(@recipe)
    assert_not Recipe.exists?(recipe_id)
  end

  test "should show published recipes in index" do
    get recipes_url
    assert_includes assigns(:recipes), recipes(:one)
    assert_not_includes assigns(:recipes), recipes(:three)
  end

  test "should show recipe" do
    get recipe_url(@recipe)
    assert_response :success
  end
end

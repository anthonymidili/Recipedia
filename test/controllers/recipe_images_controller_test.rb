require "test_helper"

class RecipeImagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
    @recipe_image = recipe_images(:one)
  end

  test "should require authentication for new" do
    get new_recipe_recipe_image_url(@recipe)
    assert_redirected_to new_user_session_path
  end

  test "should get new when authenticated" do
    sign_in(@user)
    get new_recipe_recipe_image_url(@recipe)
    assert_response :success
  end

  test "should require authentication to create" do
    assert_no_difference("RecipeImage.count") do
      post recipe_recipe_images_url(@recipe), params: {
        recipe_image: { image: fixture_file_upload("test_image.jpg", "image/jpeg") }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create recipe image when authenticated" do
    sign_in(@user)
    assert_difference("RecipeImage.count") do
      post recipe_recipe_images_url(@recipe), params: {
        recipe_image: { image: fixture_file_upload("test_image.jpg", "image/jpeg") }
      }
    end
  end

  test "should destroy recipe image when owner" do
    sign_in(@user)
    image_id = @recipe_image.id

    delete recipe_recipe_image_url(@recipe, @recipe_image)

    assert_not RecipeImage.exists?(image_id)
  end

  test "should not destroy other user's recipe image" do
    other_user = users(:two)
    sign_in(other_user)
    image_id = @recipe_image.id

    delete recipe_recipe_image_url(@recipe, @recipe_image)

    assert RecipeImage.exists?(image_id)
  end
end

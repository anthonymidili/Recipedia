require "test_helper"

class RecipeImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get recipe_images_new_url
    assert_response :success
  end

  test "should get create" do
    get recipe_images_create_url
    assert_response :success
  end

  test "should get destroy" do
    get recipe_images_destroy_url
    assert_response :success
  end
end

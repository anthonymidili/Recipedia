require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @category = categories(:one)
  end

  test "should get index" do
    get categories_url
    assert_response :success
  end

  test "should get more action" do
    get categories_url(action: :more)
    assert_response :success
  end

  test "should get show" do
    get category_url(@category)
    assert_response :success
  end

  test "should get new when authenticated" do
    sign_in(@user)
    get new_category_url
    assert_response :success
  end

  test "should require authentication to create category" do
    get new_category_url
    assert_redirected_to new_user_session_path
  end

  test "should create category when authenticated" do
    sign_in(@user)
    assert_difference("Category.count") do
      post categories_url, params: {
        category: { name: "New Category" }
      }
    end
    assert_redirected_to category_url(Category.last)
  end

  test "should not create duplicate category" do
    sign_in(@user)
    assert_no_difference("Category.count") do
      post categories_url, params: {
        category: { name: @category.name }
      }
    end
  end

  test "should get edit when owner" do
    sign_in(@user)
    get edit_category_url(@category)
    assert_response :success
  end

  test "should update category when owner" do
    sign_in(@user)
    new_name = "Updated Category"
    patch category_url(@category), params: {
      category: { name: new_name }
    }
    assert_redirected_to category_url(@category)
    @category.reload
    assert_equal new_name, @category.name
  end

  test "should destroy category when owner" do
    sign_in(@user)
    category_id = @category.id
    delete category_url(@category)
    assert_not Category.exists?(category_id)
  end
end

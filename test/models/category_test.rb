require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @category = categories(:one)
  end

  test "should create category with valid attributes" do
    category = create_category(@user)
    assert category.persisted?
  end

  test "category requires name" do
    category = @user.categories.build
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "category name must be unique" do
    @user.categories.create!(name: "Unique Category")
    category = @user.categories.build(name: "Unique Category")
    assert_not category.valid?
    assert_includes category.errors[:name], "has already been taken"
  end

  test "category belongs to user" do
    assert_equal @user, @category.user
  end

  test "category has many recipes through categorizations" do
    assert_equal 2, @category.recipes.count
  end

  test "category has many categorizations" do
    assert @category.categorizations.count > 0
  end

  test "in_use? returns true when recipes exist" do
    assert @category.in_use?
  end

  test "in_use? returns false when no recipes" do
    empty_category = create_category(@user)
    assert_not empty_category.in_use?
  end

  test "oldest_to_newest scope orders by created_at asc" do
    sorted = Category.oldest_to_newest
    dates = sorted.map(&:created_at)
    assert_equal dates, dates.sort
  end

  test "in_use scope returns only categories with recipes" do
    in_use = Category.in_use
    assert_includes in_use, @category
  end

  test "not_used scope returns only unused categories" do
    empty_category = create_category(@user)
    not_used = Category.not_used
    assert_includes not_used, empty_category
  end

  test "list_names scope returns comma separated names" do
    names = Category.limit(2).list_names
    assert names.include?(@category.name)
    assert names.include?(",")
  end

  test "category can have multiple recipes" do
    recipe1 = recipes(:one)
    recipe2 = recipes(:two)
    assert_includes @category.recipes, recipe1
    assert_includes @category.recipes, recipe2
  end
end

require "test_helper"

class RecipeValidationEdgeCasesTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @category = create_category(@user)
  end

  test "recipe with empty string name is invalid" do
    recipe = @user.recipes.build(
      name: "",
      category_ids: [ @category.id ]
    )

    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "can't be blank"
  end

  test "recipe with only whitespace name is invalid" do
    recipe = @user.recipes.build(
      name: "   ",
      category_ids: [ @category.id ]
    )

    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "can't be blank"
  end

  test "recipe without categories is invalid" do
    recipe = @user.recipes.build(name: "Test Recipe")

    assert_not recipe.valid?
    assert_includes recipe.errors[:base], "Must have at least one category selected"
  end

  test "recipe can have multiple categories" do
    category2 = create_category(@user)
    recipe = @user.recipes.build(
      name: "Multi-Category Recipe",
      category_ids: [ @category.id, category2.id ]
    )

    assert recipe.save
    assert_equal 2, recipe.categories.count
  end

  test "multiple parts require names" do
    recipe = @user.recipes.build(
      name: "Multi-Part Recipe",
      category_ids: [ @category.id ]
    )

    recipe.parts.build(name: "Part 1")
    recipe.parts.build(name: "")

    assert_not recipe.valid?
    assert_includes recipe.errors[:base], "Must name recipe parts if more than 1"
  end

  test "single part can be unnamed" do
    recipe = @user.recipes.build(
      name: "Single-Part Recipe",
      category_ids: [ @category.id ],
      parts_attributes: [ { name: "" } ]
    )

    assert recipe.valid?
  end

  test "all parts named is valid" do
    recipe = @user.recipes.build(
      name: "Well-Named Recipe",
      category_ids: [ @category.id ]
    )

    recipe.parts.build(name: "Part 1")
    recipe.parts.build(name: "Part 2")

    assert recipe.valid?
  end

  test "published defaults to false" do
    recipe = @user.recipes.build(
      name: "New Recipe",
      category_ids: [ @category.id ]
    )

    assert_equal false, recipe.published
  end

  test "can create published recipe" do
    recipe = @user.recipes.build(
      name: "Published Recipe",
      category_ids: [ @category.id ],
      published: true
    )

    assert recipe.save
    assert recipe.published?
  end

  test "recipe belongs to user" do
    recipe = create_recipe(@user)
    assert_equal @user, recipe.user
  end
end

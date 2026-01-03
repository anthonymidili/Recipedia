require "test_helper"

class RecipeSlugTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "slug is generated from name on create" do
    recipe = @user.recipes.build(name: "Chocolate Chip Cookies")
    category = create_category(@user)
    recipe.category_ids = [ category.id ]
    recipe.save!

    assert_equal "chocolate-chip-cookies", recipe.slug
  end

  test "slug is updated when name changes" do
    recipe = create_recipe(@user, name: "Original Name")
    original_slug = recipe.slug

    recipe.update!(name: "New Name")

    assert_not_equal original_slug, recipe.slug
    assert_equal "new-name", recipe.slug
  end

  test "slug is unique per user" do
    recipe1 = create_recipe(@user, name: "Test Recipe")
    recipe2 = @user.recipes.build(name: "Test Recipe")
    category = create_category(@user)
    recipe2.category_ids = [ category.id ]
    recipe2.save!

    assert_not_equal recipe1.slug, recipe2.slug
    assert_match(/test-recipe/, recipe2.slug)
  end

  test "different users can have same slug" do
    user2 = create_user

    recipe1 = create_recipe(@user, name: "Pasta")
    recipe2 = create_recipe(user2, name: "Pasta")

    assert_equal "pasta", recipe1.slug
    assert_equal "pasta", recipe2.slug
  end

  test "slug handles special characters" do
    recipe = create_recipe(@user, name: "Mom's Apple Pie & Ice Cream!")

    assert_match(/mom/, recipe.slug)
    assert_match(/apple/, recipe.slug)
    assert_match(/pie/, recipe.slug)
    assert_no_match(/[&!']/, recipe.slug)
  end

  test "to_param returns user slug and recipe slug" do
    recipe = create_recipe(@user, name: "Test Recipe")
    assert_equal "#{@user.slug}/#{recipe.slug}", recipe.to_param
  end

  test "slug is auto-generated even if set to nil" do
    recipe = @user.recipes.build(name: "Test")
    category = create_category(@user)
    recipe.category_ids = [ category.id ]
    recipe.slug = nil
    recipe.valid?

    # Slug gets generated during validation
    assert_not_nil recipe.slug
  end

  test "slug uniqueness is scoped to user" do
    recipe1 = create_recipe(@user, name: "Test")
    recipe2 = @user.recipes.build(name: "Test")
    category = create_category(@user)
    recipe2.category_ids = [ category.id ]

    # Same name generates different slug or saves
    assert recipe2.save
  end
end

require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  def setup
    @recipe = recipes(:one)
    @user = @recipe.user
  end

  test "should create recipe with valid attributes" do
    category = create_category(@user)
    recipe = @user.recipes.build(
      name: "New Recipe",
      category_ids: [ category.id ]
    )
    assert recipe.save
  end

  test "recipe requires name" do
    recipe = @user.recipes.build
    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "can't be blank"
  end

  test "recipe requires at least one category" do
    recipe = @user.recipes.build(name: "Test Recipe")
    assert_not recipe.valid?
    assert_includes recipe.errors[:base], "Must have at least one category selected"
  end

  test "recipe requires part names if more than one part" do
    category = create_category(@user)
    recipe = Recipe.new(
      user: @user,
      name: "Test Recipe",
      category_ids: [ category.id ]
    )
    # Build parts directly to ensure both are created (nested attributes with blank name gets rejected)
    recipe.parts.build(name: "Part 1")
    recipe.parts.build(name: "")
    assert_not recipe.valid?
    assert_includes recipe.errors[:base], "Must name recipe parts if more than 1"
  end

  test "recipe can have single unnamed part" do
    category = create_category(@user)
    recipe = @user.recipes.build(
      name: "Test Recipe",
      category_ids: [ category.id ],
      parts_attributes: [ { name: "" } ]
    )
    assert recipe.valid?
  end

  test "published? returns true when published" do
    assert @recipe.published?
  end

  test "published? returns false when not published" do
    unpublished_recipe = recipes(:three)
    assert_not unpublished_recipe.published?
  end

  test "recipe has many ingredients" do
    assert @recipe.ingredients.count >= 1
  end

  test "recipe has many steps" do
    assert @recipe.steps.count >= 1
  end

  test "recipe has many categories" do
    assert_equal 2, @recipe.categories.count
  end

  test "recipe has many reviews" do
    # Ensure at least one review exists
    reviews(:one)
    assert @recipe.reviews.count > 0
  end

  test "recipe has many recipe images" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @recipe.recipe_images
  end

  test "recipe belongs to user" do
    assert_equal @user, @recipe.user
  end

  test "recipe broadcasts after commit on create" do
    category = create_category(@user)
    recipe = @user.recipes.build(
      name: "Broadcast Test",
      published: true,
      category_ids: [ category.id ]
    )
    # Test that job is enqueued
    assert_enqueued_with(job: NotifiyUsersJob) do
      recipe.save
    end
  end

  test "recipe by_published scope filters published recipes" do
    published = Recipe.by_published
    assert_includes published, @recipe
    assert_not_includes published, recipes(:three)
  end

  test "recipe by_unpublished scope filters unpublished recipes" do
    unpublished = Recipe.by_unpublished
    assert_includes unpublished, recipes(:three)
    assert_not_includes unpublished, @recipe
  end

  test "recipe by_name scope orders by name" do
    sorted = Recipe.by_name
    names = sorted.map(&:name)
    assert_equal names, names.sort
  end

  test "recipe newest_to_oldest scope orders by created_at desc" do
    recipes = Recipe.newest_to_oldest
    dates = recipes.map(&:created_at)
    assert_equal dates, dates.sort.reverse
  end

  test "recipe filtered_by scope searches by name" do
    results = Recipe.filtered_by("Pasta")
    assert_includes results, @recipe
  end

  test "recipe filtered_by scope is case insensitive" do
    results = Recipe.filtered_by("pasta")
    assert_includes results, @recipe
  end

  test "recipe unique_images scope excludes used recipes" do
    used = [ @recipe.id ]
    unique = Recipe.unique_images(used)
    assert_not_includes unique, @recipe
  end

  test "recipe last_with_image scope returns last recipe with image" do
    # Ensure there's a recipe with image
    recipe_with_image = FactoryBot.create(:recipe)
    FactoryBot.create(:recipe_image, recipe: recipe_with_image, user: recipe_with_image.user)

    used = []
    last_recipe = Recipe.last_with_image(used)
    assert_not_nil last_recipe
    assert_respond_to last_recipe, :recipe_images
    assert last_recipe.recipe_images.any?
  end
end

require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  def setup
    @ingredient = ingredients(:one)
    @recipe = @ingredient.recipe
  end

  test "should create ingredient with valid attributes" do
    part = @recipe.parts.first || @recipe.parts.create!(name: "Main")
    ingredient = part.ingredients.build(
      item: "Flour",
      quantity: "2 cups"
    )
    assert ingredient.save
  end

  test "ingredient belongs to recipe" do
    assert_equal @recipe, @ingredient.recipe
  end

  test "ingredient can have different units" do
    part = @recipe.parts.first || @recipe.parts.create!(name: "Main")
    units = [ "cup", "tbsp", "tsp", "ml", "g", "oz" ]
    units.each do |unit|
      ingredient = part.ingredients.build(
        item: "Test",
        quantity: "1 #{unit}"
      )
      assert ingredient.valid?
    end
  end

  test "ingredient stores quantity as string" do
    part = @recipe.parts.first || @recipe.parts.create!(name: "Main")
    ingredient = part.ingredients.build(
      item: "Salt",
      quantity: "1.5 tsp"
    )
    assert ingredient.save
    assert_equal "1.5 tsp", ingredient.quantity
  end
end

class StepTest < ActiveSupport::TestCase
  def setup
    @step = steps(:one)
    @recipe = @step.recipe
  end

  test "should create step with valid attributes" do
    part = @recipe.parts.first || @recipe.parts.create!(name: "Main")
    step = part.steps.build(
      step_order: 3,
      description: "Mix ingredients"
    )
    assert step.save
  end

  test "step belongs to recipe" do
    assert_equal @recipe, @step.recipe
  end

  test "step stores description" do
    part = @recipe.parts.first || @recipe.parts.create!(name: "Main")
    description = "Preheat oven to 350°F"
    step = part.steps.build(
      step_order: 1,
      description: description
    )
    assert step.save
    assert_equal description, step.description.to_plain_text
  end
end

class FavoritismTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @recipe = recipes(:one)
  end

  test "should create favoritism with valid attributes" do
    favoritism = Favoritism.new(user: @user, recipe: @recipe)
    assert favoritism.save
  end

  test "favoritism belongs to user" do
    favoritism = Favoritism.create!(user: @user, recipe: @recipe)
    assert_equal @user, favoritism.user
  end

  test "favoritism belongs to recipe" do
    favoritism = Favoritism.create!(user: @user, recipe: @recipe)
    assert_equal @recipe, favoritism.recipe
  end

  test "user can favorite multiple recipes" do
    recipe1 = recipes(:one)
    recipe2 = recipes(:two)

    Favoritism.create!(user: @user, recipe: recipe1)
    Favoritism.create!(user: @user, recipe: recipe2)

    assert_equal 2, @user.favoritisms.count
  end

  test "recipe can be favorited by multiple users" do
    user1 = users(:one)
    user2 = users(:two)
    recipe = recipes(:one)

    Favoritism.create!(user: user1, recipe: recipe)
    Favoritism.create!(user: user2, recipe: recipe)

    assert_equal 2, recipe.favoritisms.count
  end
end

class CategorizationTest < ActiveSupport::TestCase
  def setup
    @recipe = recipes(:one)
    @category = categories(:one)
  end

  test "should create categorization with valid attributes" do
    categorization = Categorization.new(recipe: @recipe, category: @category)
    assert categorization.save
  end

  test "categorization belongs to recipe" do
    categorization = Categorization.create!(recipe: @recipe, category: @category)
    assert_equal @recipe, categorization.recipe
  end

  test "categorization belongs to category" do
    categorization = Categorization.create!(recipe: @recipe, category: @category)
    assert_equal @category, categorization.category
  end

  test "recipe can have multiple categories" do
    cat1 = categories(:one)
    cat2 = categories(:two)

    # Clear any pre-existing categories from fixture wiring
    @recipe.categories.clear

    @recipe.categorizations.create!(category: cat1)
    @recipe.categorizations.create!(category: cat2)

    assert_equal 2, @recipe.categories.count
  end
end

require "test_helper"

# Shared setup helper — builds a recipe with a real part, ingredient, and step
module OrderingSetup
  def setup
    @user   = create_user
    @recipe = create_recipe(@user)
    @part   = Part.create!(name: "Main", recipe: @recipe)
  end
end

# ---------------------------------------------------------------------------
# Ingredient ordering — model tests
# ---------------------------------------------------------------------------
class IngredientOrderModelTest < ActiveSupport::TestCase
  include OrderingSetup

  test "ingredients are returned in ingredient_order ascending by default" do
    third  = Ingredient.create!(item: "Butter", quantity: "2 tbsp", ingredient_order: 3, part: @part, recipe: @recipe)
    first  = Ingredient.create!(item: "Flour",  quantity: "1 cup",  ingredient_order: 1, part: @part, recipe: @recipe)
    second = Ingredient.create!(item: "Sugar",  quantity: "½ cup",  ingredient_order: 2, part: @part, recipe: @recipe)

    ordered_ids = @part.ingredients.map(&:id)
    assert_equal [ first.id, second.id, third.id ], ordered_ids
  end

  test "ingredient_order can be set on create" do
    ingredient = Ingredient.create!(item: "Salt", quantity: "1 tsp", ingredient_order: 5, part: @part, recipe: @recipe)
    assert_equal 5, ingredient.ingredient_order
  end

  test "ingredient_order can be updated" do
    ingredient = Ingredient.create!(item: "Pepper", quantity: "a pinch", ingredient_order: 1, part: @part, recipe: @recipe)
    ingredient.update!(ingredient_order: 99)
    assert_equal 99, ingredient.reload.ingredient_order
  end

  test "ingredients with nil ingredient_order sort after ordered ones (postgres ASC NULLS LAST)" do
    no_order   = Ingredient.create!(item: "Old ingredient", quantity: "1", ingredient_order: nil, part: @part, recipe: @recipe)
    with_order = Ingredient.create!(item: "New ingredient", quantity: "1", ingredient_order: 1,   part: @part, recipe: @recipe)

    ids = @part.ingredients.map(&:id)
    assert ids.index(with_order.id) < ids.index(no_order.id),
      "Expected ordered ingredient to sort before the nil-order one (ASC NULLS LAST)"
  end

  test "ingredient requires item" do
    ingredient = Ingredient.new(quantity: "1 cup", part: @part, recipe: @recipe)
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:item], "can't be blank"
  end
end

# ---------------------------------------------------------------------------
# Ingredient ordering — controller tests (nested attributes round-trip)
# ---------------------------------------------------------------------------
class IngredientOrderControllerTest < ActionDispatch::IntegrationTest
  include OrderingSetup

  test "ingredient_order is saved when recipe is updated via nested attributes" do
    sign_in(@user)
    ing = Ingredient.create!(item: "Egg", quantity: "1", ingredient_order: 1, part: @part, recipe: @recipe)

    patch user_recipe_path(@user.slug, @recipe.slug), params: {
      recipe: {
        name: @recipe.name,
        category_ids: @recipe.category_ids,
        parts_attributes: {
          "0" => {
            id: @part.id,
            name: @part.name,
            ingredients_attributes: {
              "0" => { id: ing.id, item: ing.item, quantity: ing.quantity, ingredient_order: "7" }
            }
          }
        }
      }
    }

    assert_equal 7, ing.reload.ingredient_order
  end

  test "new ingredient is created with ingredient_order via nested attributes" do
    sign_in(@user)

    assert_difference "Ingredient.count", 1 do
      patch user_recipe_path(@user.slug, @recipe.slug), params: {
        recipe: {
          name: @recipe.name,
          category_ids: @recipe.category_ids,
          parts_attributes: {
            "0" => {
              id: @part.id,
              name: @part.name,
              ingredients_attributes: {
                "0" => { item: "Vanilla", quantity: "1 tsp", ingredient_order: "3" }
              }
            }
          }
        }
      }
    end

    new_ingredient = Ingredient.find_by(item: "Vanilla")
    assert_not_nil new_ingredient
    assert_equal 3, new_ingredient.ingredient_order
  end
end

# ---------------------------------------------------------------------------
# Step ordering — model tests
# ---------------------------------------------------------------------------
class StepOrderModelTest < ActiveSupport::TestCase
  include OrderingSetup

  test "steps are returned in step_order ascending by default" do
    third  = Step.create!(step_order: 3, description: "Bake", part: @part, recipe: @recipe)
    first  = Step.create!(step_order: 1, description: "Mix",  part: @part, recipe: @recipe)
    second = Step.create!(step_order: 2, description: "Pour", part: @part, recipe: @recipe)

    ordered_ids = @part.steps.map(&:id)
    assert_equal [ first.id, second.id, third.id ], ordered_ids
  end

  test "step_order can be set on create" do
    step = Step.create!(step_order: 4, description: "Rest", part: @part, recipe: @recipe)
    assert_equal 4, step.step_order
  end

  test "step_order can be updated" do
    step = Step.create!(step_order: 1, description: "Whisk", part: @part, recipe: @recipe)
    step.update!(step_order: 10)
    assert_equal 10, step.reload.step_order
  end

  test "step requires step_order" do
    step = Step.new(description: "Missing order", part: @part, recipe: @recipe)
    assert_not step.valid?
    assert_includes step.errors[:step_order], "can't be blank"
  end
end

# ---------------------------------------------------------------------------
# Step ordering — controller tests (nested attributes round-trip)
# ---------------------------------------------------------------------------
class StepOrderControllerTest < ActionDispatch::IntegrationTest
  include OrderingSetup

  test "step_order is saved when recipe is updated via nested attributes" do
    sign_in(@user)
    step = Step.create!(step_order: 1, description: "Mix", part: @part, recipe: @recipe)

    patch user_recipe_path(@user.slug, @recipe.slug), params: {
      recipe: {
        name: @recipe.name,
        category_ids: @recipe.category_ids,
        parts_attributes: {
          "0" => {
            id: @part.id,
            name: @part.name,
            steps_attributes: {
              "0" => { id: step.id, description: step.description.to_plain_text, step_order: "5" }
            }
          }
        }
      }
    }

    assert_equal 5, step.reload.step_order
  end

  test "new step is created with step_order via nested attributes" do
    sign_in(@user)

    assert_difference "Step.count", 1 do
      patch user_recipe_path(@user.slug, @recipe.slug), params: {
        recipe: {
          name: @recipe.name,
          category_ids: @recipe.category_ids,
          parts_attributes: {
            "0" => {
              id: @part.id,
              name: @part.name,
              steps_attributes: {
                "0" => { description: "Fold gently", step_order: "2" }
              }
            }
          }
        }
      }
    end

    new_step = Step.find_by(step_order: 2)
    assert_not_nil new_step
    assert_equal "Fold gently", new_step.description.to_plain_text
  end
end

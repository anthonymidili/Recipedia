class Ingredient < ApplicationRecord
  before_validation :set_recipe

  belongs_to :recipe
  belongs_to :part

  validates :item, presence: true

  after_save :clear_nutrition_data
  after_destroy :clear_nutrition_data

  default_scope -> { order(ingredient_order: :asc) }

private

  def set_recipe
    self.recipe = part.recipe
  end

  def clear_nutrition_data
    recipe.update_column(:nutrition_data, nil) if recipe.persisted?
  end
end

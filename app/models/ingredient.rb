class Ingredient < ApplicationRecord
  before_validation :set_recipe

  belongs_to :recipe
  belongs_to :part

  validates :item, presence: true

  default_scope -> { order(ingredient_order: :asc) }

private

  def set_recipe
    self.recipe = part.recipe
  end
end

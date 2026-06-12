class BackfillIngredientOrder < ActiveRecord::Migration[8.1]
  def up
    # For each part, assign ingredient_order based on created_at order
    Part.find_each do |part|
      part.ingredients.unscoped.where(part_id: part.id).order(:created_at).each_with_index do |ingredient, index|
        ingredient.update_columns(ingredient_order: index + 1)
      end
    end
  end

  def down
    Ingredient.update_all(ingredient_order: nil)
  end
end

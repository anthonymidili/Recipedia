class AddNutritionDataToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :nutrition_data, :jsonb
  end
end

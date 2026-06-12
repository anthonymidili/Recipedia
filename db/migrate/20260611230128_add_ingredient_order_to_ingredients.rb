class AddIngredientOrderToIngredients < ActiveRecord::Migration[8.1]
  def change
    add_column :ingredients, :ingredient_order, :integer
  end
end

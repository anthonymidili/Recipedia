class AddRatingsToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :average_rating, :decimal, default: 0.0, precision: 3, scale: 2
    add_column :recipes, :ratings_count, :integer, default: 0
  end
end

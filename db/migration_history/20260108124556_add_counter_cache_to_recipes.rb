class AddCounterCacheToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :reviews_count, :integer, default: 0, null: false
    add_column :recipes, :favoritisms_count, :integer, default: 0, null: false

    # Reset counters for existing records
    reversible do |dir|
      dir.up do
        Recipe.find_each do |recipe|
          Recipe.reset_counters(recipe.id, :reviews, :favoritisms)
        end
      end
    end
  end
end

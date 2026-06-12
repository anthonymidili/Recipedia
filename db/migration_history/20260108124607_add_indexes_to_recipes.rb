class AddIndexesToRecipes < ActiveRecord::Migration[8.1]
  def change
    # Composite index for published recipes ordered by date (index action)
    add_index :recipes, [ :published, :created_at ], name: "index_recipes_on_published_and_created_at"

    # Index for name search queries (filtered_by scope)
    add_index :recipes, :name, name: "index_recipes_on_name"
  end
end

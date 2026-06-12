class ChangeRecipeSlugIndexToGlobalUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :recipes, [ :user_id, :slug ]
    add_index :recipes, :slug, unique: true
  end
end

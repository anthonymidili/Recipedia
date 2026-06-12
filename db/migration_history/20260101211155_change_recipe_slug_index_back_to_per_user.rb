class ChangeRecipeSlugIndexBackToPerUser < ActiveRecord::Migration[8.1]
  def change
    remove_index :recipes, :slug
    add_index :recipes, [ :user_id, :slug ], unique: true
  end
end

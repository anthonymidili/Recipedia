class AddPublishedToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :published, :boolean, default: true
  end
end

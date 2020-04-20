class PublishedTrueToRecipes < ActiveRecord::Migration[6.0]
  def change
    change_column :recipes, :published, :boolean, default: true
  end
end

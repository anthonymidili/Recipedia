class RemoveImageDataOnRecipes < ActiveRecord::Migration[5.2]
  def change
    remove_column :recipes, :image_data, :text
  end
end

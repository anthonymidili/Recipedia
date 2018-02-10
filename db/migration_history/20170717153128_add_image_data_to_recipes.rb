class AddImageDataToRecipes < ActiveRecord::Migration[5.1]
  def change
    add_column :recipes, :image_data, :text
  end
end

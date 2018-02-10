class RemoveImageToCategories < ActiveRecord::Migration[5.1]
  def change
    remove_column :categories, :image_data
  end
end

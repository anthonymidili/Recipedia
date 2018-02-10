class AddBannerToCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :image_data, :text
  end
end

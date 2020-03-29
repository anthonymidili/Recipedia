class SetRecipePublishedFalse < ActiveRecord::Migration[6.0]
  def change
    change_column :recipes, :published, :boolean, default: false
  end
end

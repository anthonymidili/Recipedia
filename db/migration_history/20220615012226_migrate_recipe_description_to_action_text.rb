class MigrateRecipeDescriptionToActionText < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper
  def change
    rename_column :recipes, :description, :old_description
    Recipe.all.each do |recipe|
      recipe.update_attribute(:description, simple_format(recipe.old_description))
    end
    remove_column :recipes, :old_description
  end
end

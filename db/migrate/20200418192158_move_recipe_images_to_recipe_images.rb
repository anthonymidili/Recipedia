class MoveRecipeImagesToRecipeImages < ActiveRecord::Migration[6.0]
  def up
    Recipe.all.each do |recipe|
      recipe.images.each do |image|
        recipe_image = recipe.recipe_images.create(user: recipe.user)
        recipe_image.image.attach(image.blob)
      end
      ActiveStorage::Attachment.where(record_type: 'Recipe', record_id: recipe).delete_all
    end
  end

  def down
    RecipeImage.destroy_all
  end
end

class RecipeImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe
  before_action :remove_images, only: [:create]
  rescue_from ActionController::ParameterMissing, with: :no_image_uploaded


  def new
    @recipe_image = @recipe.recipe_images.build
  end

  def create
    @recipe_image = @recipe.recipe_images.build(recipe_image_params)
    @recipe_image.user = current_user

    respond_to do |format|
      if @recipe_image.save
        format.html { redirect_to new_recipe_recipe_image_path(@recipe), notice: 'Images were successfully updated.' }
        format.json { render :new, status: :ok, location: new_recipe_recipe_image_path(@recipe) }
      else
        format.html { render :new }
        format.json { render json: @recipe_image.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def remove_images
    @recipe_images = @recipe.recipe_images.where(id: recipe_image_params[:remove_images])
    if @recipe_images
      # Only remove images if current_user is the recipe owner or the recipe_image owner.
      @recipe_images.owners_only(current_user).destroy_all
    end
  end

  def recipe_image_params
    params.require(:recipe_image).permit(:image, remove_images: [])
  end

  def no_image_uploaded
    redirect_to new_recipe_recipe_image_path(@recipe), notice: 'No image uploaded.'
  end
end

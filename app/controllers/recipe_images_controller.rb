class RecipeImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe
  rescue_from ActionController::ParameterMissing, with: :no_image_uploaded


  def new
    @recipe_image = @recipe.recipe_images.build
  end

  def create
    @recipe_image = @recipe.recipe_images.build(recipe_image_params)
    @recipe_image.user = current_user

    respond_to do |format|
      if @recipe_image.save
        format.html { redirect_to new_user_recipe_recipe_image_path(@recipe.user.slug, @recipe.slug),
          notice: "Images were successfully updated." }
        format.json { render :new, status: :ok, location: new_user_recipe_recipe_image_path(@recipe.user.slug, @recipe.slug) }
      else
        format.html { render :new }
        format.json { render json: @recipe_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @recipe_image = @recipe.recipe_images.find_by(id: params[:id])
    if is_author?(@recipe.user) || is_author?(@recipe_image.user)
      @recipe_image.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("recipe_image_thumb_#{@recipe_image.id}") }
        format.html {
          redirect_to new_user_recipe_recipe_image_path(@recipe.user.slug, @recipe.slug),
          notice: "Image was successfully removed."
        }
        format.json { head :no_content }
      end
    end
  end

private

  def set_recipe
    user = User.find_by!(slug: params[:username])
    @recipe = user.recipes.find_by!(slug: params[:recipe_slug])
  end

  def recipe_image_params
    params.require(:recipe_image).permit(:image)
  end

  def no_image_uploaded
    redirect_to new_user_recipe_recipe_image_path(@recipe.user.slug, @recipe.slug), notice: "No image uploaded."
  end
end

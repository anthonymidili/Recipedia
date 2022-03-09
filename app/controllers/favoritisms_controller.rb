class FavoritismsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def create
    favoritism = current_user.favoritisms.build
    favoritism.recipe = @recipe

    respond_to do |format|
      if favoritism.save
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("favor_form_recipe_#{@recipe.id}",
          partial: "recipes/unfavor", locals: { recipe: @recipe })
        end
        format.html { redirect_to @recipe }
      end
    end
  end

  def destroy
    current_user.find_favoritism(@recipe).destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("favor_form_recipe_#{@recipe.id}",
        partial: "recipes/favor", locals: { recipe: @recipe })
      end
      format.html { redirect_to @recipe }
    end
  end

private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
end

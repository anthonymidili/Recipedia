class FavoritismsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def create
    favoritism = current_user.favoritisms.build(favoritism_params)
    respond_to do |format|
      if favoritism.save
        format.html { redirect_to @recipe }
        format.js
      end
    end
  end

  def destroy
    current_user.find_favoitisum(@recipe).destroy
    respond_to do |format|
      format.html { redirect_to @recipe }
      format.js
    end
  end

private

  def set_recipe
    @recipe = Recipe.find(favoritism_params[:recipe_id])
  end

  def favoritism_params
    params.require(:favoritism).permit(:recipe_id)
  end
end

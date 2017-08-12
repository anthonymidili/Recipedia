class FavoritismsController < ApplicationController
  def create
    @recipe = Recipe.find(favoritism_params[:recipe_id])
    favoritism = current_user.favoritisms.build(favoritism_params)
    respond_to do |format|
      if favoritism.save
        format.html { redirect_to @recipe }
        format.js
      end
    end
  end

  def destroy
    @recipe = Recipe.find(favoritism_params[:recipe_id])
    current_user.find_favoitisum(@recipe).destroy
    respond_to do |format|
      format.html { redirect_to @recipe }
      format.js
    end
  end

private

  def favoritism_params
    params.require(:favoritism).permit(:recipe_id)
  end
end

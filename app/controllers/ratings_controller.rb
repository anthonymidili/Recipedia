class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe

  def create
    @rating = @recipe.ratings.find_or_initialize_by(user: current_user)
    @rating.score = params[:score]

    if @rating.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug), notice: "Rating saved." }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug), alert: "Could not save rating." }
      end
    end
  end

  private

  def set_recipe
    user = User.find_by!(slug: params[:username])
    @recipe = user.recipes.find_by!(slug: params[:recipe_slug])
  end
end

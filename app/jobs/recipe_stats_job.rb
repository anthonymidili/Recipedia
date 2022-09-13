class RecipeStatsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(recipe_id)
    recipe = Recipe.find_by(id: recipe_id)

    RecipeChannel.broadcast_to recipe,
    # Update all recipe review count(s).
    reviews_count: recipe.reviews.count,
    # Render likes_count partial.
    likes_partial: render_likes_partial(recipe)
  end

private

  def render_likes_partial(recipe)
    RecipesController.render(
      partial: "recipes/likes_count", locals: { recipe: recipe }
    )
  end
end

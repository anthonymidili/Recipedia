class CountReviewsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(recipe)
    RecipeChannel.broadcast_to recipe, count: recipe.reviews.count
  end
end

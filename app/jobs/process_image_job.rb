class ProcessImageJob < ApplicationJob
  queue_as :default

  def perform(recipe)
    medium_image(recipe.image).processed.service_url
  end
end

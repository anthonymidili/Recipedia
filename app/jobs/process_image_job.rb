require 'image_processing/mini_magick'

class ProcessImageJob < ApplicationJob
  queue_as :default

  def perform(recipe)
    recipe.update_attribute(:description, 'Made it!')

    # include ImageProcessing::MiniMagick
    # pipeline = ImageProcessing::MiniMagick.source(recipe.image)
    # size_800 = pipeline.resize_to_limit!(800, 800)
    # size_400 = pipeline.resize_to_limit!(400, 400)
    # size_150 = pipeline.resize_to_fill!(800, 150)
    # {large: size_800, medium: size_400, banner: size_150}
  end
end

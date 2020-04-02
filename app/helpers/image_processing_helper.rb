module ImageProcessingHelper
  def medium_image(image)
    image.variant(resize_to_fill: [400, 400]).processed.service_url
  end

  def banner_image(image)
    image.variant(resize_to_fill: [600, 200]).processed.service_url
  end

  def avatar_image(image, size)
    image.variant(resize_to_fill: [size, size]).processed.service_url
  end
end

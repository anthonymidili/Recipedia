module ImageProcessingHelper
  def large_image(image)
    image.variant(resize_to_fill: [800, 800])
  end

  def medium_image(image)
    image.variant(resize_to_fill: [400, 400])
  end

  def banner_image(image)
    image.variant(resize_to_fill: [600, 400])
  end

  def avatar_image(image, size)
    image.variant(resize_to_fill: [size, size])
  end
end

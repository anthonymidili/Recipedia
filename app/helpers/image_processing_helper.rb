module ImageProcessingHelper
  def medium_image(image)
    image.variant(combine_options: {
      auto_orient: true,
      gravity: "center",
      resize: "400x400^",
      crop: "400x400+0+0"
      }).processed.service_url
  end

  def banner_image(image)
    image.variant(combine_options: {
      auto_orient: true,
      gravity: "center",
      resize: "800x150^",
      crop: "800x150+0+0"
      }).processed.service_url
  end

  def avatar_image(image, size)
    image.variant(resize_to_fill: [size, size]).processed.service_url
  end
end

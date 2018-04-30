module RecipesHelper
  def links_to_categories(recipe)
    recipe.categories.map { |category|
      link_to category.name, category
    }.join(', ').html_safe
  end

  def background_banner(recipe)
    if recipe.try(:image).try(:attached?)
      "background-image: url(#{banner_image(recipe.image)});"
    end
  end

  def large_image(image)
    image.variant(combine_options: {
      auto_orient: true,
      gravity: "center",
      resize: "800x800^",
      crop: "800x800+0+0"
      }).processed.service_url
  end

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
end

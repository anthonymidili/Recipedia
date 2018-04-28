module RecipesHelper
  def links_to_categories(recipe)
    recipe.categories.map { |category|
      link_to category.name, category
    }.join(', ').html_safe
  end

  def background_banner(object)
    if object.try(:image).try(:attached?)
      "background-image: url(#{url_for(object.image) if object.image.attached?});"
    end
  end

  def medium_image(image)
    image.variant(combine_options: {
      auto_orient: true,
      gravity: "center",
      resize: "400x400^",
      crop: "400x400+0+0"
      })
  end
end

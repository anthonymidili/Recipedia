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
end

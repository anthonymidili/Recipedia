module RecipesHelper
  def links_to_categories(recipe)
    recipe.categories.map { |category|
      link_to category.name, category
    }.join(', ').html_safe
  end

  def background_banner(object)
    if object.try(:image).try(:attached?)
      "background-image: url(#{url_for(object.image)});"
    end
  end
end

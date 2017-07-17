module RecipesHelper
  def links_to_categories(recipe)
    recipe.categories.map { |category|
      link_to category.name, category
    }.join(', ').html_safe
  end

  def background_banner(object)
    if object.try(:image_data?)
      "background-image: url(#{object.image_url(:banner)});"
    end
  end
end

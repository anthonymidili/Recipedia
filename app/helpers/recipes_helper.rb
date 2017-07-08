module RecipesHelper
  def links_to_categories(recipe)
    recipe.categories.map {
      |category| link_to category.name, category
    }.join(', ').html_safe
  end
end

module RecipesHelper
  def links_to_categories(recipe)
    recipe.categories.map { |category|
      link_to category.name, category
    }.join(", ").html_safe
  end

  def background_banner(recipe)
    if recipe.try(:image).try(:attached?)
      "background-image: url(#{banner_image(recipe.image)});"
    end
  end

  def recipe_json_ld(recipe)
    return unless recipe.published?

    recipe_image = recipe.recipe_images.first
    image_url = if recipe_image&.image&.attached?
      Rails.application.routes.url_helpers.rails_blob_url(recipe_image.image, only_path: false)
    end

    # Collect all ingredients from all parts
    ingredients = recipe.parts.flat_map do |part|
      part.ingredients.map do |ingredient|
        if ingredient.quantity.present?
          "#{ingredient.quantity} #{ingredient.item}"
        else
          ingredient.item
        end
      end
    end

    # Collect all steps from all parts
    instructions = recipe.parts.flat_map do |part|
      part.steps.map do |step|
        {
          "@type": "HowToStep",
          "text": step.description.to_plain_text
        }
      end
    end

    json_ld = {
      "@context": "https://schema.org",
      "@type": "Recipe",
      "name": recipe.name,
      "author": {
        "@type": "Person",
        "name": recipe.user.username
      },
      "datePublished": recipe.created_at.iso8601,
      "description": recipe.description.to_plain_text.presence || recipe.name,
      "recipeIngredient": ingredients,
      "recipeInstructions": instructions
    }

    # Optional fields
    json_ld[:image] = image_url if image_url
    json_ld[:recipeCategory] = recipe.categories.map(&:name) if recipe.categories.any?

    tag.script(type: "application/ld+json") do
      json_ld.to_json.html_safe
    end
  end
end

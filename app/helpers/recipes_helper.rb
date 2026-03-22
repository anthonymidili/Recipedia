module RecipesHelper
  def recipe_form_url(recipe)
    recipe.new_record? ? recipes_path : user_recipe_path(recipe.user.slug, recipe.slug)
  end

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

    recipe_url = user_recipe_url(recipe.user.slug, recipe.slug)

    # Build image array: provide original + recommended aspect ratio variants
    # Google recommends 16:9, 4:3, and 1:1 images for best rich result eligibility
    images = recipe.recipe_images.select { |ri| ri.image.attached? }.flat_map do |ri|
      [
        url_for(ri.image.variant(resize_to_fill: [ 1200, 675 ])),  # 16:9
        url_for(ri.image.variant(resize_to_fill: [ 1200, 900 ])),  # 4:3
        url_for(ri.image.variant(resize_to_fill: [ 800, 800 ]))    # 1:1
      ]
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

    # Collect all steps from all parts with position for Google eligibility
    position = 0
    instructions = recipe.parts.flat_map do |part|
      part.steps.map do |step|
        position += 1
        {
          "@type": "HowToStep",
          "position": position,
          "text": step.description.to_plain_text
        }
      end
    end

    json_ld = {
      "@context": "https://schema.org",
      "@type": "Recipe",
      "@id": recipe_url,
      "url": recipe_url,
      "name": recipe.name,
      "author": {
        "@type": "Person",
        "name": recipe.user.username
      },
      "publisher": {
        "@type": "Organization",
        "name": "Recipedia",
        "url": root_url
      },
      "datePublished": recipe.created_at.iso8601,
      "dateModified": recipe.updated_at.iso8601,
      "description": recipe.description.to_plain_text.presence || recipe.name,
      "recipeIngredient": ingredients,
      "recipeInstructions": instructions
    }

    json_ld[:image] = images if images.any?
    json_ld[:recipeCategory] = recipe.categories.map(&:name) if recipe.categories.any?
    json_ld[:keywords] = recipe.categories.map(&:name).join(", ") if recipe.categories.any?

    tag.script(type: "application/ld+json") do
      json_ld.to_json.html_safe
    end
  end
end

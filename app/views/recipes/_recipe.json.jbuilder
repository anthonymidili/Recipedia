json.extract! recipe, :id, :name, :description, :created_at, :updated_at
json.url user_recipe_url(recipe.user.slug, recipe.slug, format: :json)

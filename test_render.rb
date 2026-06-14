require_relative 'config/environment'
recipe = Recipe.first
user = recipe.user
puts ApplicationController.renderer.render(partial: "ratings/form", locals: { recipe: recipe, user_rating: nil })

module NotificationsHelper
  def link_to_notifiable(notifiable, action)
    case notifiable.class.name
    when "Recipe"
      link_to action, user_recipe_url(notifiable.user.slug, notifiable.slug)
    when "RecipeImage"
      link_to action, user_recipe_url(notifiable.recipe.user.slug, notifiable.recipe.slug, image: notifiable.id)
    when "Review"
      link_to action, user_recipe_url(notifiable.recipe.user.slug, notifiable.recipe.slug, anchor: "review_#{notifiable.id}")
    when "Relationship"
      link_to action, user_url(notifiable.user)
    when "Favoritism"
      link_to action, user_url(notifiable.user)
    else
      link_to "Home",  root_url
    end
  end

  def hide_if(statement)
    "hidden" unless statement
  end
end

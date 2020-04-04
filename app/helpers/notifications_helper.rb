module NotificationsHelper
  def link_to_notifiable(notifiable, action)
    case notifiable.class.name
    when 'Recipe'
      link_to action, recipe_url(notifiable)
    when 'Review'
      link_to action, recipe_url(notifiable.recipe, anchor: "review_#{notifiable.id}")
    when 'Relationship'
      link_to action, user_url(notifiable.user)
    when 'Favoritism'
      link_to action, user_url(notifiable.user)
    else
      link_to 'Home',  root_url
    end
  end
end

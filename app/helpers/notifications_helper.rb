module NotificationsHelper
  def link_to_notifiable(notifiable, action)
    case notifiable.class.name
    when 'Recipe'
      link_to action, notifiable
    when 'Review'
      link_to action, recipe_path(notifiable.recipe, anchor: "review_#{notifiable.id}")
    else
      link_to 'Home',  root_path
    end
  end
end

module RatingsHelper
  def user_rating_for(recipe)
    current_user&.find_rating(recipe)
  end

  def rating_display_score(recipe, user_rating = nil)
    user_rating&.score || recipe.average_rating.to_f.round
  end

  def can_rate_recipe?(recipe)
    user_signed_in? && !is_author?(recipe.user)
  end
end

module UsersHelper
  def is_author?(user)
    user == current_user
  end

  def is_site_admin?
    @is_site_admin ||=
      if user_signed_in? && current_user.email == ENV.fetch("SITE_ADMIN", false)
        true
      else
        false
      end
  end

  def user_is_site_admin?(user)
    if user_signed_in? && user.email == ENV.fetch("SITE_ADMIN", false)
      true
    else
      false
    end
  end
end

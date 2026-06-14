module UsersHelper
  def is_author?(user)
    user == current_user
  end

  def is_site_admin?(user = current_user)
    user.present? && user.email == ENV.fetch("SITE_ADMIN", false)
  end
end

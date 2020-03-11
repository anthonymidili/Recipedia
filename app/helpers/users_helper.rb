module UsersHelper
  def is_author?(user)
    user == current_user
  end
end

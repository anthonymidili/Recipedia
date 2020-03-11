module ReviewsHelper
  def remote_form?
    if controller_name == "reviews" && action_name == "edit"
      true # non remote form.
    else
      false # remote form.
    end
  end
end

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    if params[:body].present?
      return redirect_to root_path
    end
    super
  end
end

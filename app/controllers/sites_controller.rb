class SitesController < ApplicationController
  def index
    redirect_to recipes_path if user_signed_in?
  end
end

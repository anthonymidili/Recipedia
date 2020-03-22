class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :remove_avatar, only: [:update]

  def show
  end

  def edit
  end

  def update
    @user.avatar.attach(user_params[:avatar]) if user_params[:avatar]

    respond_to do |format|
      if user_params && @user.update(user_params)
        format.html { redirect_to @user, notice: 'Avatar was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def set_user
    @user = User.find_by(slug: params[:id])
  end

  def user_params
    params.require(:user).permit(:avatar, :remove_avatar,
      info_attributes: [:id, :body, :_destroy])
  end

  def remove_avatar
    @user.avatar.purge if user_params[:remove_avatar] == "1"
  end
end

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    @user.avatar.attach(user_params[:avatar]) if user_params && user_params[:avatar]

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
    params.require(:user).permit(:avatar) if params[:user]
  end
end

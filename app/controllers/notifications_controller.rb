class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
  end

  def mark_as_read
    @notifications = current_user.notifications.by_unread.mark_as_read
    @unread_notifications_count = current_user.notifications.unread_count
    respond_to do |format|
      format.js
    end
  end

  def unread_count
    @unread_notifications_count = current_user.notifications.unread_count
    respond_to do |format|
      format.js
    end
  end

  def defaults
    @notification_default = current_user.notification_default || current_user.create_notification_default
  end

  def update_defaults
    @notification_default = current_user.notification_default
    respond_to do |format|
      if @notification_default.update(notification_default_params)
        format.html { redirect_to defaults_notifications_path, notice: 'Notification defaults were successfully updated.' }
        format.json { render :default, status: :ok, location: defaults_notifications_path }
      else
        format.html { render :default }
        format.json { render json: @notification_default.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def notification_default_params
    params.require(:notification_default).permit(:receive_email, :recipe_created,
      :review_created, :follows_you, :recipe_favored)
  end
end

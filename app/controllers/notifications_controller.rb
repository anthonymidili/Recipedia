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

  def settings
    @notification_setting = current_user.notification_setting || current_user.create_notification_setting
  end

  def update_settings
    @notification_setting = current_user.notification_setting
    respond_to do |format|
      if @notification_setting.update(notification_setting_params)
        format.html { redirect_to settings_notifications_path, notice: 'Notification settings were successfully updated.' }
        format.json { render :setting, status: :ok, location: settings_notifications_path }
      else
        format.html { render :setting }
        format.json { render json: @notification_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def notification_setting_params
    params.require(:notification_setting).permit(:receive_email, :recipe_created,
      :image_uploaded, :review_created, :follows_you, :recipe_favored)
  end
end

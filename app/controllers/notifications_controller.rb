class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
  end

  def mark_as_read
    @notifications = current_user.notifications.by_unread.mark_as_read
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
end

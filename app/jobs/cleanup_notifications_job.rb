class CleanupNotificationsJob < ApplicationJob
  queue_as :low_priority
  sidekiq_options retry: 3

  def perform
    Notification.where("created_at < :time", time: Time.current - 1.month).destroy_all
  end
end

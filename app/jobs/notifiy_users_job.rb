class NotifiyUsersJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(notifiable)
    # NotifyUsers.new(notifiable)
  end
end

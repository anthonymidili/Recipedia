class NotifiyUsersJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(notifiable_class, notifiable_id)
    notifiable = notifiable_class.find_by(id: notifiable_id)

    if notifiable
      NotifyUsers.new(notifiable)
    end
  end
end

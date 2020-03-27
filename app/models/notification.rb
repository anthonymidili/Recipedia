class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :notifier, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
end

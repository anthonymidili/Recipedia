class Relationship < ApplicationRecord
  after_commit on: [:create] do
    NotifiyUsersJob.perform_later(self)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :user, inverse_of: :relationships
  belongs_to :followed, class_name: 'User', inverse_of: :relationships
end

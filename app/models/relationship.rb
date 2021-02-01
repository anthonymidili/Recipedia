class Relationship < ApplicationRecord
  after_commit on: [:create] do
    NotifiyUsersJob.perform_later(self)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :user, foreign_key: :user_id, class_name: 'User', inverse_of: :relationships
  belongs_to :followed, foreign_key: :followed_id, class_name: 'User', inverse_of: :relationships
end

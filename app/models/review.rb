class Review < ApplicationRecord
  after_commit on: [:create] do
    NotifiyUsersJob.perform_later(self)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe
  belongs_to :user

  default_scope { order(created_at: :desc) }

  validates :body, presence: true
end

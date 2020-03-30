class Review < ApplicationRecord
  after_commit NotifyFollowers, on: [:create]

  belongs_to :recipe
  belongs_to :user

  has_many :notifications, as: :notifiable, dependent: :destroy

  default_scope { order(created_at: :desc) }

  validates :body, presence: true
end

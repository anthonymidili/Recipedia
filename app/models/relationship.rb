class Relationship < ApplicationRecord
  after_commit NotifyUsers, on: [:create]
  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :user, inverse_of: :relationships
  belongs_to :followed, class_name: 'User', inverse_of: :relationships
end

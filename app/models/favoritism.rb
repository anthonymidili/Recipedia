class Favoritism < ApplicationRecord
  after_commit NotifyUsers, on: [:create]
  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe, inverse_of: :favoritisms
  belongs_to :user, inverse_of: :favoritisms
end

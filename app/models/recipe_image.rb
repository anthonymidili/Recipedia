class RecipeImage < ApplicationRecord
  after_commit NotifyUsers, on: [:create]
  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe
  belongs_to :user

  has_one_attached :image
end

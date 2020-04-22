class RecipeImage < ApplicationRecord
  after_commit NotifyUsers, on: [:create]
  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe
  belongs_to :user

  has_one_attached :image

  attr_accessor :remove_images

  scope :owners_only, -> (current_user) {
    includes(:recipe).where(user: current_user).
    or(includes(:recipe).where(recipes: { user: current_user }))
  }
end

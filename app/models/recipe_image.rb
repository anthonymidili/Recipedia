class RecipeImage < ApplicationRecord
  after_commit on: [:create] do
    NotifiyUsersJob.perform_later(self)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe
  belongs_to :user

  has_one_attached :image

  # Always show the first image then order the rest from newest to oldest.
  # [1, 2, 3, 4] becomes [1, 4, 3, 2]
  scope :by_original_first, -> { self.rotate(1).reverse }
end

class RecipeImage < ApplicationRecord
  after_commit on: [:create] do
    NotifiyUsersJob.perform_later(self)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe
  belongs_to :user

  has_one_attached :image
end

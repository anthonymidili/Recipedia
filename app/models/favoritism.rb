class Favoritism < ApplicationRecord
  after_commit on: [ :create ] do
    NotifiyUsersJob.perform_later(self)
  end

  after_commit do
    RecipeStatsJob.perform_later(self.recipe)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe, inverse_of: :favoritisms
  belongs_to :user, inverse_of: :favoritisms
end

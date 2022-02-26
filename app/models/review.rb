class Review < ApplicationRecord
  after_commit on: [:create] do
    NotifiyUsersJob.perform_later(self)
  end
  after_create_commit do
    broadcast_prepend_later_to "reviews",
    target: "recipe_#{recipe.id}_reviews",
    partial: "reviews/review_frame", locals: { review: self }
    broadcast_replace_later_to "reviews",
    target: "recipe_#{recipe.id}_reviews_count",
    partial: "reviews/count", locals: { recipe: self.recipe }
  end
  after_update_commit { broadcast_replace_to "reviews" }
  after_destroy_commit { broadcast_remove_to "reviews" }

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe
  belongs_to :user

  default_scope { order(created_at: :desc) }

  validates :body, presence: true
end

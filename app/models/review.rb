class Review < ApplicationRecord
  after_create_commit :after_create_broadcast
  after_update_commit :after_update_broadcast
  after_destroy_commit :after_destroy_broadcast

  has_rich_text :body

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :recipe, counter_cache: true, touch: true
  belongs_to :user

  default_scope { order(created_at: :desc) }

  validates :body, presence: true

  private

  def after_create_broadcast
    broadcast_prepend_later_to "reviews",
    target: "recipe_#{recipe.id}_reviews",
    partial: "reviews/review_frame", locals: { review: self }

    RecipeStatsJob.perform_later(self.recipe)
    NotifiyUsersJob.perform_later(self)
  end

  def after_update_broadcast
    broadcast_replace_later_to "reviews",
    target: "review_#{self.id}",
    partial: "reviews/review_frame", locals: { review: self }
  end

  def after_destroy_broadcast
    broadcast_remove_to "reviews",
    target: "review_#{self.id}"

    RecipeStatsJob.perform_later(self.recipe)
  end
end

class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { scope: :recipe_id, message: "has already rated this recipe" }
  validate :cannot_rate_own_recipe

  after_commit :update_recipe_average, on: [:create, :update, :destroy]

  private

  def cannot_rate_own_recipe
    if recipe.present? && user_id == recipe.user_id
      errors.add(:base, "You cannot rate your own recipe")
    end
  end

  private

  def update_recipe_average
    recipe.update_columns(
      average_rating: recipe.ratings.average(:score).to_f.round(1),
      ratings_count: recipe.ratings.count
    )
  end
end

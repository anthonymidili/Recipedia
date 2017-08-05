class Step < ApplicationRecord
  before_validation :set_recipe

  belongs_to :recipe
  belongs_to :part

  validates :description, presence: true

  default_scope -> { order(created_at: :asc) }

  private

  def set_recipe
    self.recipe = part.recipe
  end
end

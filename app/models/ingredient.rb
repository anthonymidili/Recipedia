class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :item, presence: true
  validates :quantity, presence: true

  scope :by_order, -> { order(created_at: :asc) }
end

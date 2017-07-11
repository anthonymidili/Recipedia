class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :item, presence: true
  validates :quantity, presence: true
end

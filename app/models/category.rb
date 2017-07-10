class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :recipes, through: :categorizations

  validates :name, presence: true, uniqueness: true

  scope :in_use, -> { includes(:recipes).where.not(recipes: { id: nil }) }
  scope :list_names, -> { all.map(&:name).join(', ') }
end

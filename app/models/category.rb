class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :recipes, through: :categorizations

  belongs_to :user

  validates :name, presence: true, uniqueness: true

  scope :oldest_to_newest, -> { order(created_at: :asc) }
  scope :in_use, -> { includes(:recipes).where.not(recipes: { id: nil, published: false }) }
  scope :not_used, -> { includes(:recipes).where(recipes: { id: nil }) }
  scope :list_names, -> { pluck(:name).join(', ') }

  def in_use?
    recipes.any?
  end
end

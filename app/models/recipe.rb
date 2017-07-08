class Recipe < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  validates :name, presence: true

  def category_names
    categories.map(&:name).join(', ')
  end
end

class Recipe < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  validates :name, presence: true
  validates :description, presence: true
end

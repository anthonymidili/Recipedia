class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :recipes, through: :categorizations

  validates :name, presence: true
end

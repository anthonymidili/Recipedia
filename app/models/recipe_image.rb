class RecipeImage < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  attr_accessor :remove_images

  has_one_attached :image
end

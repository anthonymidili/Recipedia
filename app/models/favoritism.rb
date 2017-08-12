class Favoritism < ApplicationRecord
  belongs_to :recipe, inverse_of: :favoritisms
  belongs_to :user, inverse_of: :favoritisms
end

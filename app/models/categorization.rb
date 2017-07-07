class Categorization < ApplicationRecord
  belongs_to :category, inverse_of: :categorizations
  belongs_to :recipe, inverse_of: :categorizations
end

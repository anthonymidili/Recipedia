class Relationship < ApplicationRecord
  belongs_to :user, inverse_of: :relationships
  belongs_to :followed, class_name: 'User', inverse_of: :relationships
end

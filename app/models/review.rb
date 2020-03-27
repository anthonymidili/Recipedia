class Review < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  default_scope { order(created_at: :desc) }

  validates :body, presence: true
end

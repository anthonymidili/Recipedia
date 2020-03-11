class Review < ApplicationRecord
  belongs_to :recipe
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  default_scope { order(created_at: :desc) }

  validates :body, presence: true
end

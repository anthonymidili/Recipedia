class Step < ApplicationRecord
  belongs_to :recipe

  validates :description, presence: true

  scope :by_order, -> { order(created_at: :asc) }
end

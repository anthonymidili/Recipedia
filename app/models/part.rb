class Part < ApplicationRecord
  belongs_to :recipe

  has_many :ingredients, dependent: :destroy
  accepts_nested_attributes_for :ingredients, reject_if: :all_blank, allow_destroy: true

  has_many :steps, dependent: :destroy
  accepts_nested_attributes_for :steps, reject_if: :description_blank, allow_destroy: true

  default_scope -> { order(created_at: :asc) }

  def ingredients_list
    ingredients.map(&:item).join(', ')
  end

private

 def description_blank(attributes)
   attributes['description'].blank?
 end
end

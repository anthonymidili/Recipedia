class Recipe < ApplicationRecord
  has_many :favoritisms, dependent: :destroy
  has_many :users, through: :favoritisms

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy

  has_many :parts, dependent: :destroy
  accepts_nested_attributes_for :parts, allow_destroy: true

  has_one_attached :image

  belongs_to :user

  validates :name, presence: true
  validates :description, presence: true
  validate :check_box_presence
  validate :name_on_parts

  scope :by_name, -> { order(name: :asc) }
  scope :newest_to_oldest, -> { order(created_at: :desc) }
  scope :unique_image, -> (used_recipes) { where.not(id: used_recipes) }
  scope :last_with_image, -> { select { |r| r.image.attached? } .last }
  scope :filtered_by, -> (term) { where('name like ?', "%#{term}%") }

private

  def check_box_presence
    errors.add(:base, 'Must have at least one category selected') if category_ids.blank?
  end

  def name_on_parts
    parts_count = self.parts.map.count
    parts_name_count = self.parts.map(&:name).reject(&:empty?).count
    if parts_count > 1 && parts_count != parts_name_count
      errors.add(:base, 'Must name recipe parts if more than 1')
    end
  end
end

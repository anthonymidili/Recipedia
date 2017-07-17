class Recipe < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy

  has_many :parts, dependent: :destroy
  accepts_nested_attributes_for :parts, reject_if: :all_blank, allow_destroy: true

  include ImageUploader::Attachment.new(:image)

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validate :check_box_presence

  scope :by_name, -> { order(name: :asc) }
  scope :by_created, -> { order(created_at: :desc) }
  scope :last_with_image, -> { where.not(image_data: nil).last }

private

  def check_box_presence
    errors.add(:base, 'Must have at least one category selected') if category_ids.blank?
  end
end

class Recipe < ApplicationRecord
  before_validation :generate_slug

  after_commit on: [ :create, :update ] do
    NotifiyUsersJob.perform_later(self) if published
  end

  has_rich_text :description

  has_many :notifications, as: :notifiable, dependent: :destroy

  has_many :favoritisms, dependent: :destroy
  has_many :liked_users, through: :favoritisms, source: :user

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_many :reviews, dependent: :destroy

  has_many :parts, dependent: :destroy
  accepts_nested_attributes_for :parts, reject_if: :all_blank, allow_destroy: true

  has_many :recipe_images, dependent: :destroy

  belongs_to :user

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :user_id }
  # validates :description, presence: true
  validate :check_box_presence
  validate :name_on_parts

  scope :by_published, -> { where(published: true) }
  scope :by_unpublished, -> { where(published: false) }
  scope :by_name, -> { order(name: :asc) }
  scope :newest_to_oldest, -> { order(created_at: :desc) }
  scope :unique_images, ->(used_recipes) { where.not(id: used_recipes) }
  scope :last_with_image, ->(used_recipes) {
    (unique_images(used_recipes).includes(:recipe_images).where.not(recipe_images: { id: nil })).last
  }
  scope :filtered_by, ->(term) { where("name ILIKE :search", search: "%#{term}%") }

  def published?
    published == true
  end

  def to_param
    "#{user.slug}/#{slug}"
  end

private

  def generate_slug
    return if name.blank?
    # Only skip if slug exists and name hasn't changed (not for initial generation)
    return if slug.present? && !name_changed?

    base_slug = name.parameterize
    new_slug = base_slug
    counter = 1

    # Check if slug exists for this user
    while Recipe.where(user_id: user_id).where.not(id: id).exists?(slug: new_slug)
      new_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = new_slug
  end

  def check_box_presence
    errors.add(:base, "Must have at least one category selected") if category_ids.blank?
  end

  def name_on_parts
    parts_count = self.parts.map.count
    parts_name_count = self.parts.map(&:name).reject(&:empty?).count
    if parts_count > 1 && parts_count != parts_name_count
      errors.add(:base, "Must name recipe parts if more than 1")
    end
  end
end

class Recipe < ApplicationRecord
  after_commit :notifiy_followers, on: [:create, :update]

  has_many :favoritisms, dependent: :destroy
  has_many :liked_users, through: :favoritisms, source: :user

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_many :reviews, dependent: :destroy

  has_many :parts, dependent: :destroy
  accepts_nested_attributes_for :parts, reject_if: :all_blank, allow_destroy: true

  has_many :notifications, as: :notifiable, dependent: :destroy

  has_one_attached :image

  belongs_to :user

  attr_accessor :remove_image

  validates :name, presence: true
  validates :description, presence: true
  validate :check_box_presence
  validate :name_on_parts

  scope :by_published, -> { where(published: true) }
  scope :by_unpublished, -> { where(published: false) }
  scope :by_name, -> { order(name: :asc) }
  scope :newest_to_oldest, -> { order(created_at: :desc) }
  scope :unique_image, -> (used_recipes) { where.not(id: used_recipes) }
  scope :last_with_image, -> { select { |r| r.image.attached? } .last }
  scope :filtered_by, -> (term) { where('name ILIKE :search', search: "%#{term}%") }

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

  def notifiy_followers
    if published
      recipients = user.followers.by_unnotified(self)
      create_notifications(recipients)
      # future mail_notifications(recipients)
    end
  end

  def create_notifications(recipients)
    recipients.each do |recipient|
      if published
        NotifiyUserJob.perform_later(self, recipient, "created a new recipe")
      end
    end
  end

  # future
  # def mail_notifications(recipients)
  #   # bulk mail
  # end
end

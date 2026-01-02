class User < ApplicationRecord
  before_save :set_slug
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Is following users relationships.
  has_many :relationships, dependent: :destroy
  has_many :following, through: :relationships, source: :followed
  # Followed by users relationships.
  has_many :reverse_relationships, foreign_key: "followed_id",
    class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :user

  has_many :favoritisms, dependent: :destroy
  has_many :recipes, through: :favoritisms

  has_many :categories
  has_many :recipes
  has_many :reviews, dependent: :destroy
  has_many :imports, dependent: :destroy

  has_one :info, dependent: :destroy
  accepts_nested_attributes_for :info, reject_if: :all_blank, allow_destroy: true

  has_many :notifications, foreign_key: "recipient_id", dependent: :destroy
  has_one :notification_setting, dependent: :destroy

  has_one_attached :avatar, dependent: :purge_later

  attr_accessor :remove_avatar

  validates :username, presence: true, uniqueness: true

  default_scope { order(username: :asc) }
  # Finds users who received a notification about the notifiable.
  scope :by_notified, ->(notifiable) {
    includes(:notifications).where(notifications: { notifiable_id: notifiable })
  }
  # Finds users who did not receive a notification about the notifiable.
  scope :by_unnotified, ->(notifiable) { where.not(id: by_notified(notifiable)) }
  # Finds users who uploaded an image to a recipe, owns the recipe and reomves the notifier user.
  scope :by_uploaders, ->(notifiable) {
    uploaders = notifiable.recipe.recipe_images.map(&:user) << notifiable.recipe.user
    where(id: uploaders).where.not(id: notifiable.user)
  }
  # Finds users who reviewed a recipe, owns the recipe and removes the notifier user.
  scope :by_reviewers, ->(notifiable) {
    reviewers = notifiable.recipe.reviews.map(&:user) << notifiable.recipe.user
    where(id: reviewers).where.not(id: notifiable.user)
  }
  # Only email users that want to be.
  scope :recipients_email, ->(notifiable) { receive_email(notifiable).remove_recently_unread.map(&:email) }
  # Check users notification settings.
  scope :receive_email, ->(notifiable) {
    includes(:notification_setting).where(notification_settings: { id: nil }).
    or(includes(:notification_setting).where(notification_settings: { receive_email: true }).
    where(notification_settings: { receive_notification_type(notifiable) => true }))
  }
  # Finds all users that have received notifications that are unread in the past week.
  scope :by_recently_unread, -> {
    time_range = Time.current.beginning_of_day..Time.current.end_of_day
    includes(:notifications).where(notifications: { created_at: time_range }).
    where(notifications: { is_read: false })
  }
  # Remove any users that were recently notified.
  scope :remove_recently_unread, -> { where.not(id: by_recently_unread) }

  def info
    super || build_info
  end

  def find_favoritism(recipe)
    favoritisms.find_by(recipe: recipe)
  end

  def favorite_recipes
    favoritisms.map(&:recipe)
  end

  # Use :slug in params instead of :id
  def to_param
    slug
  end

  def following?(user)
    relationships.find_by(followed: user)
  end

  def mark_as_read
    # Mark notifications as read.
    notifications.by_unread.mark_as_read

    # Broadcast to current_user unread notifications count.
    MarkAsReadChannel.broadcast_to self,
    unread_notifications_count: notifications.unread_count
  end

private

  # Setter
  def set_slug
    self.slug = username.parameterize
  end

  def self.receive_notification_type(notifiable)
    case notifiable.class.name
    when "Recipe"
      :recipe_created
    when "RecipeImage"
      :image_uploaded
    when "Review"
      :review_created
    when "Relationship"
      :follows_you
    when "Favoritism"
      :recipe_favored
    end
  end
end

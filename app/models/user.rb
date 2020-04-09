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
  has_many :reverse_relationships, foreign_key: 'followed_id',
    class_name: 'Relationship', dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :user

  has_many :favoritisms, dependent: :destroy
  has_many :recipes, through: :favoritisms

  has_many :categories
  has_many :recipes
  has_many :reviews, dependent: :destroy

  has_one :info, dependent: :destroy
  accepts_nested_attributes_for :info, reject_if: :all_blank, allow_destroy: true

  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_one :notification_setting, dependent: :destroy

  has_one_attached :avatar

  attr_accessor :remove_avatar

  validates :username, presence: true, uniqueness: true

  scope :by_notified, -> (notifiable) {
    includes(:notifications).where(notifications: { notifiable_id: notifiable })
  }
  scope :by_unnotified, -> (notifiable) { where.not(id: by_notified(notifiable)) }
  scope :recent, -> {
    time_range = (Time.current - 1.week)..Time.current
    includes(:notifications).where(notifications: { created_at: time_range })
  }
  scope :receive_email, -> {
    includes(:notification_setting).where(notification_settings: {id: nil}).
    or(includes(:notification_setting).where(notification_settings: {receive_email: true}))
  }
  scope :recipients_email, -> { recent.receive_email.map(&:email) }

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

private

  # Setter
  def set_slug
    self.slug = username.parameterize
  end
end

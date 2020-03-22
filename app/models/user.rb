class User < ApplicationRecord

  before_save :set_slug
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :favoritisms, dependent: :destroy
  has_many :recipes, through: :favoritisms

  has_many :categories
  has_many :recipes
  has_many :reviews, foreign_key: 'author_id', dependent: :destroy

  has_one :info, dependent: :destroy
  accepts_nested_attributes_for :info

  has_one_attached :avatar

  attr_accessor :remove_avatar

  validates :username, presence: true, uniqueness: true

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

private

  # Setter
  def set_slug
    self.slug = username.parameterize
  end
end

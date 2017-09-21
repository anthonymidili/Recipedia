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

  validates :username, presence: true, uniqueness: true

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

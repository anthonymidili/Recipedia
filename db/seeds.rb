# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.find_by(email: 'tonywinslow@yahoo.com')

user.categories.find_or_create_by(name: 'Appetizers')
user.categories.find_or_create_by(name: 'Breakfast & Brunch')
user.categories.find_or_create_by(name: 'Lunch')
user.categories.find_or_create_by(name: 'Dinner')
user.categories.find_or_create_by(name: 'Salads & Sides')
user.categories.find_or_create_by(name: 'Desserts')
user.categories.find_or_create_by(name: 'Snacks')
user.categories.find_or_create_by(name: 'Beef')
user.categories.find_or_create_by(name: 'Poultry')
user.categories.find_or_create_by(name: 'Pork')
user.categories.find_or_create_by(name: 'Seafood')
user.categories.find_or_create_by(name: 'Pasta')
user.categories.find_or_create_by(name: 'Bread')
user.categories.find_or_create_by(name: 'Cakes')
user.categories.find_or_create_by(name: 'Pies')
user.categories.find_or_create_by(name: 'Cookies & Bars')
user.categories.find_or_create_by(name: 'Potluck')
user.categories.find_or_create_by(name: 'Slow Cooker')
user.categories.find_or_create_by(name: 'Soups')
user.categories.find_or_create_by(name: 'Sandwiches')
user.categories.find_or_create_by(name: 'Grilling')
user.categories.find_or_create_by(name: 'Vegetarian')
user.categories.find_or_create_by(name: 'Gluten Free')

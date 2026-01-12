namespace :db do
  desc "Create 100 mock users with 2 recipes each for testing"
  task create_mock_users: :environment do
    puts "Creating 100 mock users..."

    # Find or create the mock category
    admin_user = User.first || User.create!(username: "admin", email: "admin@example.com", password: "password123", password_confirmation: "password123")
    category = Category.find_or_create_by!(name: "Mock Recipes") do |c|
      c.user = admin_user
    end

    # Find the highest existing mock user number to avoid conflicts
    existing_emails = User.where("email LIKE 'user%@example.com'").pluck(:email)
    max_number = existing_emails.map { |e| e[/user(\d+)@/, 1].to_i }.max || 0
    start_number = max_number + 1

    adjectives = %w[Happy Sleepy Grumpy Bashful Doc Sneezy Dopey Quick Lazy Crazy Wild Free Easy Loud Quiet Soft Hard Fast Slow]
    nouns = %w[Cook Chef Baker Eater Foodie Gourmet Epicure Feaster Devourer Muncher Nibbler Taster Sampler]

    created_users = 0
    created_recipes = 0

    100.times do |i|
      # Generate unique username
      adjective = adjectives[i % adjectives.length]
      noun = nouns[i % nouns.length]
      number = start_number + i
      username = "#{adjective}#{noun}#{number}"

      email = "user#{number}@example.com"

      begin
        user = User.create!(
          username: username,
          email: email,
          password: "password123",
          password_confirmation: "password123"
        )

        created_users += 1

        # Create 2 mock recipes per user
        2.times do |j|
          recipe = user.recipes.build(
            name: "Mock Recipe #{j + 1} by #{username}",
            description: "A delicious mock recipe created for testing purposes.",
            source: "Mock Cookbook",
            published: true
          )

          recipe.categories << category
          recipe.save!

          created_recipes += 1

          # Create a main part
          part = recipe.parts.create!(name: "Main Dish")

          # Add some mock ingredients
          part.ingredients.create!(item: "Mock Ingredient #{j + 1}", quantity: "#{j + 1} cup")
          part.ingredients.create!(item: "Another Ingredient", quantity: "2 tbsp")

          # Add some mock steps
          part.steps.create!(description: "Prepare the ingredients", step_order: 1)
          part.steps.create!(description: "Cook everything together", step_order: 2)
          part.steps.create!(description: "Serve and enjoy", step_order: 3)
        end

        print "."
      rescue ActiveRecord::RecordInvalid => e
        puts "\nFailed to create user #{username}: #{e.message}"
      end
    end

    puts "\nCreated #{created_users} new users and #{created_recipes} new recipes"
    puts "Total users: #{User.count}, Total recipes: #{Recipe.count}"
  end

  desc "Delete all mock users and their recipes"
  task delete_mock_users: :environment do
    puts "Deleting mock users and recipes..."

    # Delete users with email pattern user##@example.com
    deleted_users = User.where("email LIKE 'user%@example.com'").destroy_all.count

    # Delete admin if it exists and was created for mocking
    admin = User.find_by(email: "admin@example.com")
    admin&.destroy

    # Delete mock category
    Category.find_by(name: "Mock Recipes")&.destroy

    puts "Deleted #{deleted_users} mock users and their associated recipes"
    puts "Total users remaining: #{User.count}, Total recipes remaining: #{Recipe.count}"
  end
end

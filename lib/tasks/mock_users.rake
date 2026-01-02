namespace :db do
  desc "Create 100 mock users for testing"
  task create_mock_users: :environment do
    puts "Creating 100 mock users..."

    adjectives = %w[Happy Sleepy Grumpy Bashful Doc Sneezy Dopey Quick Lazy Crazy Wild Free Easy Loud Quiet Soft Hard Fast Slow]
    nouns = %w[Cook Chef Baker Eater Foodie Gourmet Epicure Feaster Devourer Muncher Nibbler Taster Sampler]

    100.times do |i|
      # Generate unique username
      adjective = adjectives[i % adjectives.length]
      noun = nouns[i % nouns.length]
      number = i + 1
      username = "#{adjective}#{noun}#{number}"

      email = "user#{i + 1}@example.com"

      begin
        User.create!(
          username: username,
          email: email,
          password: "password123",
          password_confirmation: "password123"
        )
        print "."
      rescue ActiveRecord::RecordInvalid => e
        puts "\nFailed to create user #{username}: #{e.message}"
      end
    end

    puts "\nCreated #{User.count} users total"
  end
end

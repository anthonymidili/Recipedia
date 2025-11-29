#!/usr/bin/env ruby
# Quick manual test to verify image upload works without SSL errors
# Run from Rails console or as: bundle exec ruby test_image_upload.rb

require_relative 'config/environment'

puts "=" * 80
puts "Testing Image Upload with AWS SSL Fix"
puts "=" * 80

# Create a test user if needed
user = User.first || User.create!(
  username: 'test_user',
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
puts "✓ Using user: #{user.username} (id: #{user.id})"

# Create a test recipe with at least one category
category = Category.first || Category.create!(name: 'Test Category')
recipe = Recipe.create!(
  name: 'SSL Test Recipe',
  user: user,
  published: true,
  categories: [ category ]
)
puts "✓ Created recipe: #{recipe.name} (id: #{recipe.id})"

# Create a test image file in /tmp
test_image_path = '/tmp/test_image.jpg'
unless File.exist?(test_image_path)
  # Create a minimal JPEG file (1x1 pixel)
  jpeg_data = "\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xFF\xDB\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0C\x14\r\x0C\x0B\x0B\x0C\x19\x12\x13\x0F\x14\x1D\x1A\x1F\x1E\x1D\x1A\x1C\x1C $.\' \",#\x1C\x1C(7),01444\x1F\'9=82<.342\xFF\xC0\x00\x0B\x08\x00\x01\x00\x01\x01\x11\x00\xFF\xC4\x00\x1F\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0B\xFF\xDA\x00\x08\x01\x01\x00\x00?\x00\xFB\xD6\xFF\xD9"
  File.write(test_image_path, jpeg_data)
  puts "✓ Created test image at #{test_image_path}"
else
  puts "✓ Test image exists at #{test_image_path}"
end

# Upload the image
puts "\nAttempting image upload to S3..."
begin
  start_time = Time.now

  recipe_image = recipe.recipe_images.build(user: user)
  recipe_image.image.attach(
    io: File.open(test_image_path),
    filename: 'test_image.jpg',
    content_type: 'image/jpeg'
  )

  if recipe_image.save
    elapsed = Time.now - start_time
    puts "✅ SUCCESS: Image uploaded in #{elapsed.round(2)}s"
    puts "   - RecipeImage ID: #{recipe_image.id}"
    puts "   - Blob ID: #{recipe_image.image.blob.id}"
    puts "   - S3 Key: #{recipe_image.image.blob.key}"
    puts "\n✅ AWS SSL FIX IS WORKING - No CRL verification errors!"
  else
    puts "❌ FAILED: Could not save recipe image"
    puts "   Errors: #{recipe_image.errors.full_messages.join(', ')}"
  end
rescue Seahorse::Client::NetworkingError => e
  puts "❌ FAILED: SSL/Networking error"
  puts "   Error: #{e.message}"
  puts "\n⚠️  AWS SSL FIX DID NOT WORK - CRL verification still failing"
rescue => e
  puts "❌ FAILED: Unexpected error"
  puts "   Error (#{e.class}): #{e.message}"
  puts e.backtrace.first(5).join("\n   ")
end

puts "\n" + "=" * 80
puts "Test complete"
puts "=" * 80

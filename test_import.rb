require 'net/http'
require 'json'
require 'uri'

# Test URLs
allrecipes_recipe = "https://www.allrecipes.com/recipe/216271/easy-honey-glazed-ham/"
allrecipes_article = "https://www.allrecipes.com/i-tried-our-most-popular-ham-recipes-11715901"

# Test the import endpoint
def test_import(url)
  puts "\n" + "="*80
  puts "Testing: #{url}"
  puts "="*80

  uri = URI.parse("http://localhost:3000/recipes/import.json")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  request.body = { url: url }.to_json

  response = http.request(request)

  puts "Response code: #{response.code}"
  if response.body && !response.body.empty?
    begin
      data = JSON.parse(response.body)
      puts JSON.pretty_generate(data)

      if data['error']
        puts "\n✗ Error: #{data['error']}"
      elsif data['name']
        puts "\n✓ Success!"
        puts "  Name: #{data['name']}"
        puts "  Ingredients: #{data['ingredients']&.size || 0}"
        puts "  Instructions: #{data['instructions']&.size || 0}"
      end
    rescue JSON::ParserError => e
      puts "Response body: #{response.body}"
    end
  else
    puts "Empty response body"
  end
end

# Run tests
test_import(allrecipes_recipe)
test_import(allrecipes_article)

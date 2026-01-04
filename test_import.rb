require 'net/http'
require 'json'
require 'uri'

# Test URLs
allrecipes_recipe = "https://www.allrecipes.com/recipe/216271/easy-honey-glazed-ham/"
allrecipes_article = "https://www.allrecipes.com/i-tried-our-most-popular-ham-recipes-11715901"

# Login to get session
def login(email, password)
  # First, GET the sign-in page to get the CSRF token and session cookie
  uri = URI.parse("http://localhost:3000/users/sign_in")
  http = Net::HTTP.new(uri.host, uri.port)
  get_request = Net::HTTP::Get.new(uri.path)
  get_response = http.request(get_request)

  if get_response.code != '200'
    puts "Failed to get sign-in page: #{get_response.code}"
    return nil
  end

  # Extract CSRF token from the form
  token_match = get_response.body.match(/name="authenticity_token"[^>]*value="([^"]+)"/)
  csrf_token = token_match ? token_match[1] : nil

  if csrf_token.nil?
    puts "CSRF token not found"
    return nil
  end

  session_cookie = get_response['set-cookie']
  if session_cookie.nil?
    puts "No session cookie"
    return nil
  end

  # Now POST the login with CSRF token
  post_request = Net::HTTP::Post.new(uri.path)
  post_request['Cookie'] = session_cookie
  post_request.set_form_data(
    'user[email]' => email,
    'user[password]' => password,
    'authenticity_token' => csrf_token
  )

  response = http.request(post_request)

  if response.code == '302' || response.code == '303'  # Redirect on success
    cookie = response['set-cookie'] || session_cookie
    puts "Logged in successfully."
    cookie
  else
    puts "Login failed: #{response.code}"
    nil
  end
end

# Test the import endpoint
def test_import(url, cookie)
  puts "\n" + "="*80
  puts "Testing: #{url}"
  puts "="*80

  uri = URI.parse("http://localhost:3000/recipes/import.json")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'Cookie' => cookie })
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

# Replace with actual test user credentials
email = "test@example.com"
password = "password"

cookie = login(email, password)
if cookie
  # Run tests
  test_import(allrecipes_recipe, cookie)
  test_import(allrecipes_article, cookie)
else
  puts "Cannot proceed without login."
end

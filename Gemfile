source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# jQuery
gem 'jquery-rails', '~> 4.3.1'
gem 'jquery-turbolinks', '~> 2.1.0'
gem 'jquery-ui-rails', '~> 6.0.1'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Speed up boot time by caching expensive operations
gem 'bootsnap', require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'haml', '~> 5.0.1'
gem 'haml-rails', '~> 1.0.0'

gem 'foundation-rails', '~> 6.4.1'
gem 'autoprefixer-rails'
gem 'font-awesome-rails'

gem 'kaminari', '~> 1.1.1'

gem 'cocoon', '~> 1.2.10'

gem 'devise', '~> 4.5.0'

# shrine
# gem 'shrine'
gem 'mini_magick'
gem 'image_processing'
# gem 'fastimage'
gem 'aws-sdk', '~> 3'
# gem 'sidekiq', '~> 5.1.0'
# gem 'redis-rails', '~> 5.0.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Shim to load environment variables from .env
  gem 'dotenv-rails', '~> 2.5.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby '2.5.1'

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "4.0.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.3.1"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
# gem 'puma', '~> 4.1'
gem "passenger", ">= 5.0.25"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Speed up boot time by caching expensive operations
gem "bootsnap", require: false

gem "haml-rails", "~> 3.0.0"
gem "kaminari", "~> 1.2.0"
# For webpacker, you must use the cocoon gem with the yarn package cocoon-js.
gem "cocoon", "~> 1.2.10"
gem "devise", "~> 4.9.3"
# https://github.com/kpumuk/meta-tags to make site search engine friendly.
gem "meta-tags", "~> 2.22.0"
# https://github.com/kjvarga/sitemap_generator
# run [rake sitemap:refresh] in production
gem "sitemap_generator"
# Required for Ruby 4.0.0+ compatibility (cgi was removed from stdlib)
gem "cgi", "~> 0.4"
# Use ActiveStorage variant
gem "ruby-vips"
gem "image_processing", "~> 1.6"
gem "aws-sdk-s3", require: false
# Active Job backgrounding.
gem "sidekiq", "~> 8.1.0"
gem "sidekiq-scheduler", "~> 6.0.1"
# Use Redis for Action Cable
gem "redis", "~> 5.0"
# Web Push Notifications
gem "web-push"

# Required for Esbuild bundling.
gem "jsbundling-rails"
gem "cssbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Console tables.
gem "hirb"

gem "nokogiri"
# ActionCable to AnyCable
# gem "anycable-rails", "~> 1.0"

group :development, :test do
  # Call 'debugger' anywhere in the code to get a debugger console in the views
  gem "debug", ">= 1.0.0", require: false, platforms: :mri
  gem "dotenv-rails", "~> 3.1"
end

group :test do
  gem "minitest", "~> 5.25"
  gem "rails-controller-testing", "~> 1.0"
  gem "factory_bot_rails"
  # Required for Rails system tests (ActionDispatch::SystemTestCase)
  gem "capybara", "~> 3.39"
  gem "selenium-webdriver", "~> 4.26"
end

group :development do
  # IRB colors.
  gem "irbtools", require: "irbtools/binding"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.3"
  # gem "better_errors"
  # gem "binding_of_caller"
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data" if Gem.win_platform?

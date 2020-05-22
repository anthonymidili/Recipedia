source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Speed up boot time by caching expensive operations
gem 'bootsnap', require: false

gem 'haml-rails', '~> 2.0.0'
gem 'kaminari', '~> 1.2.0'
# For webpacker, you must use the cocoon gem with the yarn package cocoon-js.
gem 'cocoon', '~> 1.2.10'
gem 'devise', '~> 4.7.1'
# https://github.com/kpumuk/meta-tags to make site search engine friendly.
gem 'meta-tags', '~> 2.13.0'
# https://github.com/kjvarga/sitemap_generator
# run [rake sitemap:refresh] in production
gem 'sitemap_generator'
# Active Storage file processing and storage.
gem 'mini_magick', '~> 4.10.1'
gem 'image_processing', '~> 1.10.3'
gem 'aws-sdk', '~> 3'
# Active Job backgrounding.
gem 'sidekiq', '~> 6.0.6'
# Webpack.
gem 'webpacker', '~> 5.x'
# Console tables.
gem 'hirb'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '~> 3.2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Set so sitemap.rb (rails_blob_url) method can find the url host.
Rails.application.routes.default_url_options[:host] =
  ENV.fetch("DEFAULT_URL") { "example.com" }

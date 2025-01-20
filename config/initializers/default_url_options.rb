# Set so sitemap.rb (rails_blob_url) method can find the url host.
Rails.application.routes.default_url_options[:host] =
  if Rails.env.production?
    ENV.fetch("DEFAULT_URL") { "example.com" }
  else
    "localhost:3000"
  end

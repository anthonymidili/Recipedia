require 'rubygems'
require 'aws-sdk-s3'
require 'sitemap_generator'
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://recipedia.wiki"
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.sitemaps_host = "https://console.aws.amazon.com/s3/buckets/#{Rails.application.credentials.dig(:aws, :s3_bucket)}/?region=#{Rails.application.credentials.dig(:aws, :region)}"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
  Rails.application.credentials.dig(:aws, :s3_bucket),
  aws_access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
  aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
  aws_region: Rails.application.credentials.dig(:aws, :region)
)

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  add recipes_path, priority: 0.7, changefreq: 'daily'
  #
  # Add all articles:
  #
  Recipe.find_each do |recipe|
    if recipe.recipe_images.try(:first).try(:image).try(:attached?)
      add recipe_path(recipe), lastmod: recipe.updated_at,
      images: [{
        loc: recipe.recipe_images.first.image.url,
        title: recipe.name
      }]
    else
      add recipe_path(recipe), lastmod: recipe.updated_at
    end
  end
end

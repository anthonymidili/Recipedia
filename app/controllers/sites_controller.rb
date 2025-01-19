class SitesController < ApplicationController
  def sitemap
    redirect_to "https://#{Rails.application.credentials.dig(:sitemap, :s3_bucket)}.s3.#{Rails.application.credentials.dig(:aws, :region)}.amazonaws.com/sitemaps/recipedia/sitemap.xml",
    allow_other_host: true
  end
end

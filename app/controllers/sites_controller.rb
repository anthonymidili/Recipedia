class SitesController < ApplicationController
  def sitemap
    redirect_to "https://#{Rails.application.credentials.dig(:aws, :s3_bucket)}.s3.amazonaws.com/sitemaps/sitemap.xml"
  end
end

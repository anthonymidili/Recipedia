class SitesController < ApplicationController
  def sitemap
    redirect_to "https://s3.amazonaws.com/#{Rails.application.credentials.dig(:aws, :s3_bucket)}/sitemaps/sitemap.xml",
    allow_other_host: true
  end
end

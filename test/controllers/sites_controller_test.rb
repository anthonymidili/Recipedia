require "test_helper"

class SitesControllerTest < ActionDispatch::IntegrationTest
  test "sitemap redirects to S3 bucket" do
    get "/sitemap.xml"
    assert_response :redirect
    assert_match /amazonaws\.com\/sitemaps\/recipedia\/sitemap\.xml/, response.headers["Location"]
  end
end

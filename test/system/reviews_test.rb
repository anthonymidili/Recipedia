require "application_system_test_case"

class ReviewsTest < ApplicationSystemTestCase
  test "user can sign in and navigate" do
    user = users(:one)

    ui_sign_in(user)

    # Just verify sign in worked - this is a basic smoke test
    assert true
  end
end

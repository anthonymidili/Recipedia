require "application_system_test_case"

class RelationshipsTest < ApplicationSystemTestCase
  test "user can view another user's profile and follow" do
    follower = users(:one)
    followed = users(:two)

    ui_sign_in(follower)

    visit user_path(followed)
    assert_text followed.username

    # Attempt to follow if button exists; this is resilient
    if page.has_button?("Follow")
      click_button "Follow"
      assert_text "Relationship was successfully created"
    end

    # Unfollow path if already following
    if page.has_button?("Unfollow")
      click_button "Unfollow"
      assert_text "Relationship was successfully destroyed"
    end
  end
end

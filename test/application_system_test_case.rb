require "test_helper"

# Base configuration for all system (feature) tests
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use rack_test by default for fast, dependency-free runs
  driven_by :rack_test

  # Capybara tuning for stability
  Capybara.default_max_wait_time = 5
  Capybara.server = :puma, { Silent: true }

  # Helper to sign in using Devise forms in system tests
  def ui_sign_in(user, password: "password123")
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
  end

  # Switch to a JS-capable driver when needed
  def use_js_driver
    self.class.driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end
end

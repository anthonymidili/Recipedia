require "test_helper"

class Devise::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "devise password reset functionality works" do
    user = users(:one)

    # Reset token should be nil before request
    assert_nil user.reset_password_token

    # Request password reset
    post user_password_path, params: {
      user: { email: user.email }
    }

    # Verify successful response
    assert_response :redirect
    follow_redirect!
    assert_response :success

    # Reload user to get updated attributes
    user.reload

    # Verify reset token was set (proves Devise password reset works)
    assert_not_nil user.reset_password_token
    assert_not_nil user.reset_password_sent_at

    # Verify token was generated recently
    assert user.reset_password_sent_at > 1.minute.ago
  end

  test "devise mailer has password reset functionality" do
    # This test verifies Devise mailer has reset password email capability
    # Verify Devise mailer exists and responds to reset_password_instructions
    assert_respond_to Devise.mailer, :reset_password_instructions

    # Verify Devise::Mailer class exists
    assert defined?(Devise::Mailer)
    assert Devise::Mailer.instance_methods.include?(:reset_password_instructions)
  end

  test "devise handles invalid email gracefully" do
    # Request password reset for non-existent email
    post user_password_path, params: {
      user: { email: "nonexistent@example.com" }
    }

    # Returns 422 with error (security behavior may vary)
    assert_response :unprocessable_entity
  end
end

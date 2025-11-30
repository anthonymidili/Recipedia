require "test_helper"

class NotifiyUsersMailerTest < ActionMailer::TestCase
  test "activity email" do
    notifiable = recipes(:one)
    notifier = users(:one)
    recipients = [ "test@example.com" ]
    action_statement = "created a new recipe"

    mail = NotifiyUsersMailer.activity(notifiable, notifier, recipients, action_statement)

    assert_equal "#{notifier.username} #{action_statement}", mail.subject
    assert_equal recipients, mail.bcc
    assert_match notifier.username, mail.body.encoded
  end
end

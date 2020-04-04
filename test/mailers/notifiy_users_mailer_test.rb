require 'test_helper'

class NotifiyUsersMailerTest < ActionMailer::TestCase
  test "notifiable" do
    mail = NotifiyUsersMailer.notifiable
    assert_equal "Notifiable", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "notifier" do
    mail = NotifiyUsersMailer.notifier
    assert_equal "Notifier", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "recipients" do
    mail = NotifiyUsersMailer.recipients
    assert_equal "Recipients", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end

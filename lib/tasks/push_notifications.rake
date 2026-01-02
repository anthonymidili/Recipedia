namespace :push_notifications do
  desc "Generate VAPID keys for Web Push"
  task :generate_vapid_keys do
    require "web-push"

    vapid_key = WebPush.generate_key

    puts "\n" + "="*80
    puts "VAPID Keys Generated"
    puts "="*80
    puts "\nAdd these to your Rails credentials:"
    puts "\nRun: EDITOR='code --wait' rails credentials:edit"
    puts "\nThen add this section:"
    puts "\nweb_push:"
    puts "  vapid_public_key: #{vapid_key.public_key}"
    puts "  vapid_private_key: #{vapid_key.private_key}"
    puts "\n" + "="*80
  end

  desc "Test push notification to a user"
  task :test, [ :user_id ] => :environment do |t, args|
    user = User.find(args[:user_id])

    if user.push_subscriptions.empty?
      puts "User has no push subscriptions. Enable push notifications in settings first."
      exit
    end

    notification = user.notifications.first || OpenStruct.new(
      notifiable_type: "Recipe",
      notifier: OpenStruct.new(username: "Test User"),
      action: "Test notification from Recipedia",
      id: 1
    )

    PushNotificationService.send_notification(user, notification)
    puts "Test notification sent to user #{user.username}"
  end
end

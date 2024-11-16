# Run "bundle exec rake clean_notifications" to perform.
desc "Clean old notifications"
task clean_notifications: :environment do
  puts "Cleaning notifications older than 1 month..."
  notifications = Notification.by_older_than_month
  notifications.destroy_all
  puts "#{notifications.count} Notifications deleted... done."
end

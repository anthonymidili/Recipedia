class AddImageUploadedToNotificationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :notification_settings, :image_uploaded, :boolean, default: true
  end
end

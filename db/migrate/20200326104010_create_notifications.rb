class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true, null: false, unique: true
      t.references :notifier, foreign_key: { to_table: :users }, null: false
      t.references :recipient, foreign_key: { to_table: :users }, null: false
      t.string :action, null: false
      t.boolean :is_read, default: false

      t.timestamps
    end

    rename_column :reviews, :author_id, :user_id
  end
end

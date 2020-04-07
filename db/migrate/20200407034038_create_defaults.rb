class CreateDefaults < ActiveRecord::Migration[6.0]
  def change
    create_table :notification_defaults do |t|
      t.boolean :receive_email, default: true
      t.boolean :recipe_created, default: true
      t.boolean :review_created, default: true
      t.boolean :follows_you, default: true
      t.boolean :recipe_favored, default: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

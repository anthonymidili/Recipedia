class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.references :user, foreign_key: true, null: false
      t.references :followed, foreign_key: { to_table: :users }, null: false
      t.index [ :user_id, :followed_id ], unique: true

      t.timestamps
    end

    add_index :favoritisms, [ :user_id, :recipe_id ], unique: true
  end
end

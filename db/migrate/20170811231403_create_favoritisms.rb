class CreateFavoritisms < ActiveRecord::Migration[5.1]
  def change
    create_table :favoritisms do |t|
      t.references :recipe, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end

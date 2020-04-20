class CreateRecipeImages < ActiveRecord::Migration[6.0]
  def change
    create_table :recipe_images do |t|
      t.references :recipe, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end

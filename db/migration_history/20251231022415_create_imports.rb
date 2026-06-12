class CreateImports < ActiveRecord::Migration[8.1]
  def change
    create_table :imports do |t|
      t.references :user, null: false, foreign_key: true
      t.text :title
      t.text :description
      t.text :ingredients
      t.text :instructions

      t.timestamps
    end
  end
end

class CreateCategorizations < ActiveRecord::Migration[5.1]
  def change
    create_table :categorizations do |t|
      t.references :category, foreign_key: true, null: false
      t.references :recipe, foreign_key: true, null: false

      t.timestamps
    end
  end
end

class CreateSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :steps do |t|
      t.text :description
      t.references :recipe, foreign_key: true, null: false

      t.timestamps
    end
  end
end

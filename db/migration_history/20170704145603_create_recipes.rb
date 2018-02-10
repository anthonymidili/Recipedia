class CreateRecipes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'

    create_table :recipes do |t|
      t.citext :name
      t.text :description

      t.timestamps
    end
  end
end

class CreateParts < ActiveRecord::Migration[5.1]
  class MigrationParts < ActiveRecord::Base
    self.table_name = :parts
  end

  def up
    create_table :parts do |t|
      t.string :name
      t.references :recipe, foreign_key: true, null: false

      t.timestamps
    end

    add_column :ingredients, :part_id, :integer
    add_column :steps, :part_id, :integer

    Recipe.all.each do |recipe|
      MigrationParts.create(name: 'part name', recipe_id: recipe.id)
      recipe.ingredients.update_all(part_id: recipe.parts.first.id)
      recipe.steps.update_all(part_id: recipe.parts.first.id)
    end

    change_column_null :ingredients, :part_id, false
    change_column_null :steps, :part_id, false
  end

  def down
    remove_column :ingredients, :part_id
    remove_column :steps, :part_id
    drop_table :parts
  end
end

class ChangeRenameAttrToIngredients < ActiveRecord::Migration[5.1]
  def up
    remove_column :ingredients, :unit
    change_column :ingredients, :name, :citext
    rename_column :ingredients, :name, :item
    rename_column :ingredients, :amount, :quantity
  end

  def down
    add_column :ingredients, :unit, :string
    change_column :ingredients, :item, :string
    rename_column :ingredients, :item, :name
    rename_column :ingredients, :quantity, :amount
  end
end

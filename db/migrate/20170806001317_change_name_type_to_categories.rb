class ChangeNameTypeToCategories < ActiveRecord::Migration[5.1]
  def change
    change_column :categories, :name, :citext
  end
end

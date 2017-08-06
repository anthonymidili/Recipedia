class ChangeIdsToBigint < ActiveRecord::Migration[5.1]
  def change
    change_column :categories, :user_id, :bigint
    change_column :ingredients, :part_id, :bigint
    change_column :recipes, :user_id, :bigint
    change_column :steps, :part_id, :bigint
  end
end

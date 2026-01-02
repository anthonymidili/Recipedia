class AddSourceToImports < ActiveRecord::Migration[8.1]
  def change
    add_column :imports, :source, :string
  end
end

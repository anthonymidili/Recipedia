class AddStatusAndErrorToImports < ActiveRecord::Migration[8.1]
  def change
    add_column :imports, :status, :string, default: 'pending', null: false
    add_column :imports, :error_message, :text
    add_column :imports, :url, :string
    add_index :imports, :status
  end
end

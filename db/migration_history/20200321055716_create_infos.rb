class CreateInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :infos do |t|
      t.text :body
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

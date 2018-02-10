class AddSlugToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :slug, :citext
    add_index :users, :slug, unique: true

    User.all.each do |user|
      user.update(slug: user.username.parameterize)
    end

    change_column_null :users, :slug, false
  end
end

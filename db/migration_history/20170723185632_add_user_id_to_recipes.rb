class AddUserIdToRecipes < ActiveRecord::Migration[5.1]
  def change
    add_column :recipes, :user_id, :integer
    add_column :categories, :user_id, :integer

    user = User.find_or_create_by(username: 'Anthony', email: 'tonywinslow@yahoo.com') do |u|
      u.password = 'password'
      u.password_confirmation = 'password'
    end

    Recipe.update_all(user_id: user.id)
    Category.update_all(user_id: user.id)

    change_column_null :recipes, :user_id, false
    change_column_null :categories, :user_id, false
  end
end

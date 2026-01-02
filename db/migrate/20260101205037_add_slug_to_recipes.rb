class AddSlugToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :slug, :string

    # Generate slugs for existing recipes
    reversible do |dir|
      dir.up do
        Recipe.find_each do |recipe|
          recipe.update_column(:slug, recipe.send(:generate_slug))
        end
      end
    end

    add_index :recipes, [ :user_id, :slug ], unique: true
  end
end

namespace :recipes do
  desc "Generate slugs for existing recipes"
  task generate_slugs: :environment do
    Recipe.includes(:user).find_each do |recipe|
      old_slug = recipe.slug
      recipe.slug = nil
      recipe.save
      puts "Generated slug '#{recipe.slug}' for recipe ##{recipe.id}: #{recipe.name} (was: #{old_slug})"
    end
    puts "Finished generating slugs!"
  end
end

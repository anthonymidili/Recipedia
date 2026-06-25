namespace :nutrition do
  desc "Backfill nutrition data for all recipes that don't have it yet"
  task backfill: :environment do
    recipes = Recipe.where(nutrition_data: nil)
    total = recipes.count

    puts "Found #{total} recipes without nutrition data."
    puts "Starting backfill (this may take a while depending on rate limits)..."

    success_count = 0
    failure_count = 0

    recipes.find_each.with_index do |recipe, index|
      puts "Processing #{index + 1}/#{total}: '#{recipe.name}' (ID: #{recipe.id})"
      
      begin
        # Fetch data. The service automatically saves to the DB.
        result = NutritionService.fetch_for_recipe(recipe)
        
        if result && result[:items].present?
          success_count += 1
          puts "  -> Success: Fetched nutrition data from #{result[:serving_count]} ingredients."
        else
          failure_count += 1
          puts "  -> Skipped: No ingredients or API returned no data."
        end
        
        # Sleep to avoid hitting API rate limits (API Ninjas allows ~10 req/sec, but let's be gentle)
        sleep 0.5
      rescue => e
        failure_count += 1
        puts "  -> Error: #{e.message}"
      end
    end

    puts "\nBackfill complete!"
    puts "Successfully fetched: #{success_count}"
    puts "Failed/Skipped: #{failure_count}"
  end

  desc "Force recalculate all nutrition facts"
  task recalculate: :environment do
    puts "Clearing existing nutrition data..."
    Recipe.update_all(nutrition_data: nil)
    Rake::Task["nutrition:backfill"].invoke
  end
end

class NutritionService
  API_URL = "https://api.api-ninjas.com/v1/nutrition".freeze

  # Returns nutrition data for a recipe.
  # Reads from the database if already fetched, otherwise queries the API and persists.
  def self.fetch_for_recipe(recipe)
    # Return persisted data if available
    return recipe.nutrition_data.with_indifferent_access if recipe.nutrition_data.present?

    ingredients = recipe.ingredients.includes(:part)
    return empty_nutrition if ingredients.empty?

    totals = empty_nutrition
    items = []

    ingredients.each do |ingredient|
      next if ingredient.quantity.blank?

      # Remove text inside parentheses (e.g. "(thinly sliced)") which confuses the API
      item_clean = ingredient.item.gsub(/\s*\([^)]*\)/, '').strip
      # If the ENTIRE item was in parentheses, just remove the parenthesis characters instead
      item_clean = ingredient.item.delete('()').strip if item_clean.blank?

      # Build the natural language query: "1 cup flour", "2 large eggs", etc.
      query = [ingredient.quantity, item_clean].compact_blank.join(" ")
      next if query.blank?

      result = query_api(query)
      next if result.nil?

      # API returns an array of parsed food items per query
      result.each do |food|
        totals[:calories]       += food["calories"].to_f
        totals[:fat_total_g]    += food["fat_total_g"].to_f
        totals[:fat_saturated_g] += food["fat_saturated_g"].to_f
        totals[:protein_g]      += food["protein_g"].to_f
        totals[:carbohydrates_total_g] += food["carbohydrates_total_g"].to_f
        totals[:fiber_g]        += food["fiber_g"].to_f
        totals[:sugar_g]        += food["sugar_g"].to_f
        totals[:sodium_mg]      += food["sodium_mg"].to_f
        totals[:cholesterol_mg] += food["cholesterol_mg"].to_f
        totals[:potassium_mg]   += food["potassium_mg"].to_f

        items << {
          name: food["name"],
          query: query,
          calories: food["calories"].to_f,
          protein_g: food["protein_g"].to_f,
          carbohydrates_total_g: food["carbohydrates_total_g"].to_f,
          fat_total_g: food["fat_total_g"].to_f
        }
      end
    end

    totals[:items] = items
    totals[:serving_count] = items.size

    # Persist to the database so it survives cache clears and server restarts
    recipe.update_column(:nutrition_data, totals)

    totals
  end

  private

  def self.query_api(query)
    api_key = Rails.application.credentials.dig(:api_ninjas, :api_key)
    return nil if api_key.blank?

    uri = URI(API_URL)
    uri.query = URI.encode_www_form(query: query)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = api_key
    request["Accept"] = "application/json"

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.warn "Nutrition API error for '#{query}': #{response.code} #{response.body}"
      nil
    end
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    Rails.logger.warn "Nutrition API timeout/error for '#{query}': #{e.message}"
    nil
  end

  def self.empty_nutrition
    {
      calories: 0.0,
      fat_total_g: 0.0,
      fat_saturated_g: 0.0,
      protein_g: 0.0,
      carbohydrates_total_g: 0.0,
      fiber_g: 0.0,
      sugar_g: 0.0,
      sodium_mg: 0.0,
      cholesterol_mg: 0.0,
      potassium_mg: 0.0,
      items: [],
      serving_count: 0
    }
  end
end

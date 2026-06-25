ingredients = [
  "Your favorite pizza dough-we like this pizza dough recipe",
  "1 large sweet potato (thinly sliced, about 1/4 inch thick)",
  "1/2 red onion (sliced)",
  "1 1/2 tablespoon olive oil (divided)",
  "Salt and pepper (for seasoning potato slices and onion)",
  "1 1/2 cups mozzarella cheese",
  "1 1/2 cups chopped kale",
  "1 tablespoon balsamic vinegar",
  "1 teaspoon (freshly chopped rosemary)"
]

totals = Hash.new(0)
ingredients.each do |query|
  result = NutritionService.query_api(query)
  puts "\nQuery: #{query}"
  next if result.nil?
  result.each do |food|
    puts "  Matched: #{food['name']} (serving: #{food['serving_size_g']}g)"
    puts "    Sodium: #{food['sodium_mg']} mg"
    puts "    Fat: #{food['fat_total_g']} g"
    puts "    Sat Fat: #{food['fat_saturated_g']} g"
    totals[:sodium_mg] += food['sodium_mg'].to_f
    totals[:fat_total_g] += food['fat_total_g'].to_f
    totals[:fat_saturated_g] += food['fat_saturated_g'].to_f
  end
end

puts "\nTotals:"
puts "Sodium: #{totals[:sodium_mg]} mg"
puts "Fat: #{totals[:fat_total_g]} g"
puts "Sat Fat: #{totals[:fat_saturated_g]} g"

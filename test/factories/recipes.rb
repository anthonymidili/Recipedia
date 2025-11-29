FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe #{n}" }
    association :user

    after(:create) do |recipe|
      # Ensure the recipe has at least one category to satisfy validations
      if recipe.categories.empty?
        recipe.categories << FactoryBot.create(:category, user: recipe.user)
      end
    end
    published { true }

    after(:build) do |recipe|
      # ensure at least one part
      recipe.parts << build(:part, recipe: recipe) if recipe.parts.blank?
    end
  end
end

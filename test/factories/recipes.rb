FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "Recipe #{n}" }
    association :user

    published { true }

    trait :unpublished do
      published { false }
    end

    trait :named do
      transient do
        custom_name { "Chocolate Cake" }
      end
      name { custom_name }
    end

    after(:build) do |recipe|
      # Ensure the recipe has at least one category BEFORE validation
      if recipe.categories.blank?
        cat = FactoryBot.create(:category, user: recipe.user)
        recipe.categories << cat
      end
      # ensure at least one part with ingredients and steps
      if recipe.parts.blank?
        part = build(:part, recipe: recipe)
        recipe.parts << part
        # Add an ingredient and step to the part
        part.ingredients << build(:ingredient, part: part, recipe: recipe)
        part.steps << build(:step, part: part, recipe: recipe)
      end
    end
  end
end

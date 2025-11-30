FactoryBot.define do
  factory :ingredient do
    item { "Ingredient" }
    quantity { "1" }
    association :recipe
    association :part
  end
end

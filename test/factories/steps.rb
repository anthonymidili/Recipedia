FactoryBot.define do
  factory :step do
    association :recipe
    association :part
    step_order { 1 }
    description { "Mix all ingredients" }
  end
end

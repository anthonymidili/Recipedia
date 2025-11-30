FactoryBot.define do
  factory :part do
    name { "Main" }
    association :recipe
  end
end

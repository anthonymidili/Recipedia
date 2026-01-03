FactoryBot.define do
  factory :categorization do
    association :recipe
    association :category
  end
end

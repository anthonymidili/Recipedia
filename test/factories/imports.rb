FactoryBot.define do
  factory :import do
    association :user
    url { "https://example.com/recipe" }
    status { "pending" }
  end
end

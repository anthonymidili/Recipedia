FactoryBot.define do
  factory :review do
    association :recipe
    association :user
    # Ensure body is set before validation
    after(:build) do |review|
      review.body = "Great!"
    end
  end
end

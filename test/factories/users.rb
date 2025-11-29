FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}_#{SecureRandom.hex(3)}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    slug { username.parameterize }
  end
end

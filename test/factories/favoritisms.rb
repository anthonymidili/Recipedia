FactoryBot.define do
  factory :favoritism do
    association :user
    association :recipe
  end
end

FactoryBot.define do
  factory :relationship do
    association :user, factory: :user
    association :followed, factory: :user
  end
end

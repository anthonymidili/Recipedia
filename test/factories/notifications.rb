FactoryBot.define do
  factory :notification do
    association :notifier, factory: :user
    association :recipient, factory: :user
    association :notifiable, factory: :relationship
    action { "followed" }
    is_read { false }
  end
end

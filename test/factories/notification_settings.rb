FactoryBot.define do
  factory :notification_setting do
    receive_email { false }
    recipe_created { false }
    review_created { false }
    follows_you { false }
    recipe_favored { false }
    association :user
  end
end

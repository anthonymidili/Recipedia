FactoryBot.define do
  factory :review do
    association :recipe
    association :user

    after(:create) do |review|
      # set rich text body via assignment (Action Text will persist)
      review.body = "<div>Great!</div>"
      review.save
    end
  end
end

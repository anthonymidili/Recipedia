FactoryBot.define do
  factory :recipe_image do
    association :recipe
    association :user
    after(:build) do |ri|
      # attach a tiny in-memory blob to avoid S3 in tests
      ri.image.attach(io: StringIO.new("\xFF\xD8\xFF\xD9"), filename: "test.jpg", content_type: "image/jpeg")
    end
  end
end

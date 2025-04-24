FactoryBot.define do
  factory :event do
    title { "MyString" }
    description { "MyText" }
    start_date { "2025-04-24 14:35:34" }
    end_date { "2025-04-24 14:35:34" }
    location { "MyString" }
    admin { nil }
  end
end

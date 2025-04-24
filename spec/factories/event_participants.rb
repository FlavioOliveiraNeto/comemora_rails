FactoryBot.define do
  factory :event_participant do
    event { nil }
    user { nil }
    status { "MyString" }
  end
end

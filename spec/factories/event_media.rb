FactoryBot.define do
  factory :event_medium do
    association :event
    association :medium
  end
end

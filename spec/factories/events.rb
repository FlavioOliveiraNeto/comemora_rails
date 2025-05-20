FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "Evento #{n}" }
    description { "Descrição do evento" }
    start_date { Time.current }
    end_date { 1.day.from_now }
    location { "Local do evento" }
    association :admin, factory: :user
  end
end

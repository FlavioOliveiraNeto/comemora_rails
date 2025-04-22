FactoryBot.define do
  factory :user do
    name { 'Test User' }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'Password1!' }
    password_confirmation { 'Password1!' }
    confirmed_at { Time.current }
  end
end
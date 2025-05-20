FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Usuário #{n}" }
    sequence(:email) { |n| "usuario#{n}@exemplo.com" }
    password { 'Senha@123' }
    password_confirmation { 'Senha@123' }
    role { 'guest' }
  end
end
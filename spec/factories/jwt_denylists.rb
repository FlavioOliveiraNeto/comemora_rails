FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2025-05-21 00:57:18" }
  end
end

FactoryBot.define do
  factory :medium do
    association :user
    after(:build) do |medium|
      medium.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'image.png')),
        filename: 'image.png',
        content_type: 'image/png'
      )
    end
  end
end

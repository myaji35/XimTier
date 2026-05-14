FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    name     { "Test User" }
    company  { "Acme Inc" }
    role     { "PM" }
    industry { :manufacturing }
    locale   { "ko" }
    admin    { false }

    trait :admin do
      admin { true }
    end
  end
end

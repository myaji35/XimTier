FactoryBot.define do
  factory :contact_inquiry do
    sequence(:name)  { |n| "Contact #{n}" }
    sequence(:email) { |n| "contact#{n}@example.com" }
    company  { "Acme Inc" }
    industry { :manufacturing }
    message  { "We'd like to know more about XimTier." }
    source   { "contact_form" }
    locale   { "ko" }
    handled  { false }
  end
end

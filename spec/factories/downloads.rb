FactoryBot.define do
  factory :download do
    sequence(:email) { |n| "ir#{n}@example.com" }
    sequence(:name)  { |n| "IR Visitor #{n}" }
    company  { "Acme Inc" }
    role     { "VC Analyst" }
    asset    { :ir_deck_ko }
    downloaded_count { 1 }
    locale   { "ko" }
  end
end

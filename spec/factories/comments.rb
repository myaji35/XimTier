FactoryBot.define do
  factory :comment do
    user { nil }
    demo_request { nil }
    body { "MyText" }
    by_admin { false }
  end
end

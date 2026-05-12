FactoryBot.define do
  factory :demo_request do
    user { nil }
    data_description { "MyText" }
    preferred_at { "2026-05-12 19:56:59" }
    status { 1 }
    scheduled_at { "2026-05-12 19:56:59" }
    meeting_url { "MyString" }
    admin_notes { "MyText" }
    locale { "MyString" }
    source { "MyString" }
  end
end

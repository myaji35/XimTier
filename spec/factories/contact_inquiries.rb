FactoryBot.define do
  factory :contact_inquiry do
    name { "MyString" }
    email { "MyString" }
    company { "MyString" }
    industry { 1 }
    message { "MyText" }
    source { "MyString" }
    locale { "MyString" }
    handled { false }
  end
end

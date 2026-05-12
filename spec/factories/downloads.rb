FactoryBot.define do
  factory :download do
    email { "MyString" }
    name { "MyString" }
    company { "MyString" }
    role { "MyString" }
    asset { 1 }
    download_token { "MyString" }
    downloaded_count { 1 }
    locale { "MyString" }
  end
end

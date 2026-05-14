FactoryBot.define do
  factory :demo_request do
    user
    data_description { "We have time-series sensor data and need anomaly insights." }
    preferred_at     { 3.days.from_now }
    status           { :pending }
    locale           { "ko" }
    source           { "demo_form" }
  end
end

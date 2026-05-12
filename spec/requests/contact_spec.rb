require "rails_helper"

RSpec.describe "Contact form", type: :request do
  include ActiveJob::TestHelper

  it "POST /ko/contact — DB 저장 + 메일 2통 발송 + 302 redirect" do
    perform_enqueued_jobs do
      expect {
        post "/ko/contact", params: {
        contact_inquiry: {
          name:     "김상무",
          email:    "buyer@samsung-test.com",
          company:  "테스트 제조",
          industry: "manufacturing",
          message:  "ChatGPT 입력 못 하는 데이터 분석이 필요합니다.",
          consent:  "1"
        }
      }
      }.to change(ContactInquiry, :count).by(1)
        .and change { ActionMailer::Base.deliveries.size }.by(2)
    end

    expect(response).to redirect_to("/ko/contact")
    inq = ContactInquiry.last
    expect(inq.name).to eq("김상무")
    expect(inq.industry).to eq("manufacturing")
    expect(inq.locale).to eq("ko")
  end

  it "동의 체크 없으면 422 + 저장 안 함" do
    expect {
      post "/ko/contact", params: {
        contact_inquiry: {
          name: "no consent", email: "x@y.com", message: "test"
        }
      }
    }.to_not change(ContactInquiry, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "honeypot 채워지면 302 (silently dropped)" do
    expect {
      post "/ko/contact", params: {
        website: "spam",
        contact_inquiry: {
          name: "bot", email: "bot@x.com", message: "spam", consent: "1"
        }
      }
    }.to_not change(ContactInquiry, :count)
    expect(response).to redirect_to("/ko/contact")
  end
end

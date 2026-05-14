require "rails_helper"

RSpec.describe "Contact form", type: :request do
  include ActiveJob::TestHelper

  it "POST /ko/contact — DB 저장 + 메일 2통 발송 + 슬랙 알림 + 302 redirect" do
    expect(SlackContactNotificationJob).to receive(:perform_later).with(kind_of(Integer)).and_call_original

    perform_enqueued_jobs do
      expect(SlackNotifier).to receive(:notify_contact).and_return(true)

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

  context "Turnstile 검증" do
    before do
      allow(TurnstileVerifier).to receive(:enabled?).and_return(true)
    end

    it "토큰 검증 실패 시 422 + 저장 안 함" do
      allow(TurnstileVerifier).to receive(:verify).and_return(false)

      expect {
        post "/ko/contact", params: {
          "cf-turnstile-response": "bad-token",
          contact_inquiry: {
            name: "공격자", email: "x@y.com",
            message: "bypass attempt", consent: "1"
          }
        }
      }.to_not change(ContactInquiry, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "토큰 검증 통과 시 저장됨" do
      allow(TurnstileVerifier).to receive(:verify).and_return(true)
      allow(SlackContactNotificationJob).to receive(:perform_later)

      expect {
        post "/ko/contact", params: {
          "cf-turnstile-response": "good-token",
          contact_inquiry: {
            name: "정상사용자", email: "ok@y.com",
            message: "정상 문의", consent: "1"
          }
        }
      }.to change(ContactInquiry, :count).by(1)

      expect(response).to redirect_to("/ko/contact")
    end
  end
end

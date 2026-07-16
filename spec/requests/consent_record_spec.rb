require "rails_helper"

# ISS-001 — 동의는 화면 체크로 끝나면 안 되고 DB에 시각이 남아야 한다.
# 남지 않으면 분쟁 시 동의를 받았다는 사실을 입증할 수 없다.
RSpec.describe "개인정보 수집 동의 기록", type: :request do
  include ActiveJob::TestHelper

  describe "데모 신청" do
    it "동의하면 User에 동의 시각이 기록된다" do
      perform_enqueued_jobs do
        post "/ko/demo", params: {
          demo_request: {
            name: "김상무", email: "consent@test.com", company: "테스트",
            role: "상무", industry: "manufacturing",
            data_description: "동의 기록 확인", consent: "1"
          }
        }
      end

      user = User.find_by(email: "consent@test.com")
      expect(user.privacy_agreed_at).to be_present
      expect(user.privacy_agreed_at).to be_within(1.minute).of(Time.current)
    end

    it "동의 없이는 계정이 생기지 않는다" do
      expect {
        post "/ko/demo", params: {
          demo_request: {
            name: "x", email: "noconsent@test.com", data_description: "test"
          }
        }
      }.not_to change(User, :count)
    end
  end

  describe "문의" do
    it "동의하면 ContactInquiry에 동의 시각이 기록된다" do
      perform_enqueued_jobs do
        post "/ko/contact", params: {
          contact_inquiry: {
            name: "문의자", email: "inquiry@test.com", company: "테스트",
            industry: "manufacturing", message: "문의 내용입니다", consent: "1"
          }
        }
      end

      inquiry = ContactInquiry.find_by(email: "inquiry@test.com")
      expect(inquiry).to be_present
      expect(inquiry.privacy_agreed_at).to be_present
    end
  end

  describe "IR 자료 다운로드" do
    it "동의하면 Download에 동의 시각이 기록된다" do
      perform_enqueued_jobs do
        post "/ko/company/investors", params: {
          download: {
            name: "투자자", email: "ir@test.com", company: "VC",
            role: "심사역", consent: "1"
          }
        }
      end

      dl = Download.find_by(email: "ir@test.com")
      expect(dl).to be_present
      expect(dl.privacy_agreed_at).to be_present
    end

    # IR 폼은 개인정보 4종(이름·이메일·회사·직책)을 수집하면서
    # 동의 절차 자체가 없었다 (제22조 위반).
    it "동의 없이는 IR 신청이 저장되지 않는다" do
      expect {
        post "/ko/company/investors", params: {
          download: { name: "투자자", email: "noconsent-ir@test.com", company: "VC", role: "심사역" }
        }
      }.not_to change(Download, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "기존 데이터" do
    it "동의 기록이 없는 레코드는 NULL로 남는다 (소급 기입하지 않는다)" do
      legacy = User.create!(email: "legacy@test.com", password: "secret123", locale: "ko")
      expect(legacy.privacy_agreed_at).to be_nil
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

# 동의 체크박스가 화면에 실제로 렌더링되는지 — 없으면 사용자가 제출할 수 없다.
RSpec.describe "동의 체크박스 렌더링", type: :request do
  it "IR 다운로드 폼(ko)에 동의 체크박스와 처리방침 링크가 있다" do
    get "/ko/company/investors"
    expect(response.body).to include('name="download[consent]"')
    expect(response.body).to include("/ko/privacy")
  end

  it "IR 다운로드 폼(en)에도 있다" do
    get "/en/company/investors"
    expect(response.body).to include('name="download[consent]"')
    expect(response.body).to include("/en/privacy")
  end

  it "데모 폼에 동의 체크박스가 있다" do
    get "/ko/demo"
    expect(response.body).to include('name="demo_request[consent]"')
  end

  it "문의 폼에 동의 체크박스가 있다" do
    get "/ko/contact"
    expect(response.body).to include('name="contact_inquiry[consent]"')
  end
end

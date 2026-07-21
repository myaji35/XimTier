require "rails_helper"

RSpec.describe "Demo flow", type: :request do
  include ActiveJob::TestHelper

  it "POST /ko/demo (신규 이메일) — User+DemoRequest 생성 + 접수 메일 2통" do
    perform_enqueued_jobs do
      expect {
        post "/ko/demo", params: {
          demo_request: {
            name: "김상무", email: "kim@new-test.com",
            company: "테스트 제조", role: "상무",
            industry: "manufacturing",
            data_description: "공정 로그 분석 요청",
            consent: "1"
          }
        }
      }.to change(User, :count).by(1)
        .and change(DemoRequest, :count).by(1)
        .and change { ActionMailer::Base.deliveries.size }.by(2) # received + admin
    end

    expect(response).to redirect_to("/ko")
    user = User.last
    expect(user.email).to eq("kim@new-test.com")
    expect(user.industry).to eq("manufacturing")
  end

  it "POST /ko/demo (기존 이메일) — 계정 생성·로그인 없이 신청을 접수" do
    User.create!(email: "existing@test.com", password: "secret123", name: "기존", locale: "ko")

    expect {
      perform_enqueued_jobs do
        post "/ko/demo", params: {
          demo_request: {
            name: "기존", email: "existing@test.com", company: "X", role: "Y",
            industry: "other", data_description: "재신청", consent: "1"
          }
        }
      end
    }.to change(User, :count).by(0)
      .and change(DemoRequest, :count).by(1)

    expect(response).to redirect_to("/ko")
    expect(session["warden.user.user.key"]).to be_nil
  end

  # ISS-006 회귀 방지 — 비밀번호 없이 타인 계정 세션을 얻을 수 있었던 취약점
  it "관리자 이메일로 데모 신청해도 해당 계정으로 로그인되지 않는다" do
    admin = create(:user, :admin, email: "admin@ximtier.io")

    perform_enqueued_jobs do
      post "/ko/demo", params: {
        demo_request: {
          name: "공격자", email: "admin@ximtier.io", company: "Evil", role: "X",
          industry: "other", data_description: "계정 탈취 시도", consent: "1"
        }
      }
    end

    expect(response).to redirect_to("/ko")

    # admin 세션이 열렸다면 /admin 이 통과된다 — 반드시 차단되어야 한다.
    get "/admin"
    expect(response).to redirect_to("/users/sign_in")

    expect(admin.demo_requests.count).to eq(1)
  end

  it "동의 미체크 → 422 + 저장 X" do
    expect {
      post "/ko/demo", params: {
        demo_request: {
          name: "x", email: "x@y.com",
          data_description: "test"
        }
      }
    }.to_not change(DemoRequest, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "honeypot 채워지면 302 (silently dropped)" do
    expect {
      post "/ko/demo", params: {
        website: "spam",
        demo_request: {
          name: "bot", email: "bot@x.com", data_description: "spam", consent: "1"
        }
      }
    }.to_not change(DemoRequest, :count)
    expect(response).to redirect_to("/ko/demo")
  end
end

# Devise helpers
RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

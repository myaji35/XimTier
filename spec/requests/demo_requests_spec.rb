require "rails_helper"

RSpec.describe "Demo flow", type: :request do
  include ActiveJob::TestHelper

  it "POST /ko/demo (신규 이메일) — User+DemoRequest 생성 + 메일 3통 + sign_in" do
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
        .and change { ActionMailer::Base.deliveries.size }.by(3) # welcome + received + admin
    end

    expect(response).to redirect_to("/ko/dashboard")
    user = User.last
    expect(user.email).to eq("kim@new-test.com")
    expect(user.industry).to eq("manufacturing")
  end

  it "POST /ko/demo (기존 이메일) — User 재사용, DemoRequest만 +1" do
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

RSpec.describe "Dashboard", type: :request do
  let(:user) { User.create!(email: "u@test.com", password: "secret123", name: "U", locale: "ko") }

  it "비로그인 — sign_in 페이지로 리디렉트" do
    get "/ko/dashboard"
    expect(response).to redirect_to("/users/sign_in")
  end

  it "로그인 — 200 + 본인 데모 목록" do
    user.demo_requests.create!(data_description: "내 신청", locale: "ko")
    sign_in user
    get "/ko/dashboard"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("내 신청")
  end
end

RSpec.describe "Comments", type: :request do
  let(:user)   { User.create!(email: "u@t.com", password: "secret123", name: "U", locale: "ko") }
  let(:other)  { User.create!(email: "x@t.com", password: "secret123", name: "X", locale: "ko") }
  let(:my_dr)  { user.demo_requests.create!(data_description: "내 거", locale: "ko") }

  it "본인 demo_request에 코멘트 작성 가능" do
    sign_in user
    expect {
      post "/ko/demo-requests/#{my_dr.id}/comments", params: { comment: { body: "추가 문의입니다" } }
    }.to change(Comment, :count).by(1)
    expect(response).to redirect_to("/ko/dashboard")
  end

  it "타인 demo_request에 코멘트 작성 불가 (404 또는 Comment 미생성)" do
    other_dr = other.demo_requests.create!(data_description: "남의 거", locale: "ko")
    sign_in user
    expect {
      post "/ko/demo-requests/#{other_dr.id}/comments", params: { comment: { body: "해킹 시도" } }
    }.to_not change(Comment, :count)
    expect(response.status).to be_in([404, 500])
  end
end

# Devise helpers
RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

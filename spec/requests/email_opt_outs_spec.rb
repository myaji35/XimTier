require "rails_helper"

RSpec.describe "Email opt-outs", type: :request do
  let(:email) { "Person@Example.COM" }
  let(:token) { Rails.application.message_verifier(:email_optout).generate(email) }

  it "유효한 토큰으로 확인 화면을 표시한다" do
    get "/ko/unsubscribe", params: { token: token }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Pe***@Example.COM")
    expect(response.body).to_not include(email)
  end

  it "POST 요청으로 수신거부를 등록하고 이메일을 정규화한다" do
    expect {
      post "/ko/unsubscribe", params: { token: token }
    }.to change(EmailOptOut, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(EmailOptOut.last.email).to eq("person@example.com")
    expect(EmailOptOut).to be_opted_out(" PERSON@example.com ")
  end

  it "변조된 토큰을 거부한다" do
    get "/ko/unsubscribe", params: { token: "#{token}tampered" }

    expect(response).to have_http_status(:not_found)
  end

  it "중복 수신거부를 오류 없이 처리한다" do
    2.times { post "/en/unsubscribe", params: { token: token } }

    expect(response).to have_http_status(:ok)
    expect(EmailOptOut.where(email: "person@example.com").count).to eq(1)
  end
end

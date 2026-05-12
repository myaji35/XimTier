require "rails_helper"

RSpec.describe "IR Download flow", type: :request do
  include ActiveJob::TestHelper

  it "POST /ko/company/investors — Download 저장 + 토큰 발급 + 메일 1통" do
    perform_enqueued_jobs do
      expect {
        post "/ko/company/investors", params: {
          download: {
            name:    "박사무관",
            email:   "investor@vc-test.com",
            company: "더벤처스",
            role:    "심사역",
            asset:   "ir_deck_ko"
          }
        }
      }.to change(Download, :count).by(1)
        .and change { ActionMailer::Base.deliveries.size }.by(1)
    end

    expect(response).to redirect_to(/sent=1/)
    d = Download.last
    expect(d.download_token).to be_present
    expect(d.asset).to eq("ir_deck_ko")
  end

  it "GET /ir/:token — PDF 응답 + 카운트 증가" do
    d = Download.create!(
      name: "test", email: "t@t.com", company: "x", role: "y",
      asset: "ir_deck_ko", locale: "ko"
    )
    initial = d.downloaded_count

    get "/ko/ir/#{d.download_token}"
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to start_with("application/pdf")

    expect(d.reload.downloaded_count).to eq(initial + 1)
  end

  it "GET /ir/invalid_token — investors로 redirect" do
    get "/ko/ir/totally-invalid"
    expect(response).to redirect_to("/ko/company/investors")
  end
end

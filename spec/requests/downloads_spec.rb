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
            asset:   "ir_deck_ko",
            consent: "1"
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

# 시장($81B TAM) 근거는 투자자용 자료다. 고객용 헤더 메뉴에서 분리하고
# IR 자료를 받는 이 경로로 안내한다 (2026-07-16 결정).
RSpec.describe "IR 메일의 시장 근거 안내", type: :request do
  include ActiveJob::TestHelper

  it "IR 메일에 시장 페이지 링크가 들어간다 (ko)" do
    perform_enqueued_jobs do
      post "/ko/company/investors", params: {
        download: { name: "투자자", email: "market-note@test.com", company: "VC",
                    role: "심사역", asset: "ir_deck_ko", consent: "1" }
      }
    end

    mail = ActionMailer::Base.deliveries.find { |m| m.to.include?("market-note@test.com") }
    expect(mail).to be_present

    text = mail.text_part ? mail.text_part.body.decoded : mail.body.decoded
    expect(text).to include("/ko/company/market")
    expect(text).to include("시장 근거 자료 보기")
    # 번역이 빠지면 "translation missing" 이 그대로 메일로 나간다.
    # 첫 구현에서 실제로 그랬고, 느슨한 정규식 탓에 테스트가 통과해버렸다.
    expect(text).not_to include("translation missing")
  end

  it "영문 신청에는 영문 안내가 들어간다" do
    perform_enqueued_jobs do
      post "/en/company/investors", params: {
        download: { name: "Investor", email: "market-en@test.com", company: "VC",
                    role: "Partner", asset: "ir_deck_en", consent: "1" }
      }
    end

    mail = ActionMailer::Base.deliveries.find { |m| m.to.include?("market-en@test.com") }
    expect(mail).to be_present

    text = mail.text_part ? mail.text_part.body.decoded : mail.body.decoded
    expect(text).to include("/en/company/market")
    expect(text).to include("See the market evidence")
    expect(text).not_to include("translation missing")
  end
end

require "rails_helper"

# ISS-009 — 처리방침 3항이 "IR 다운로드 토큰: 발급 후 24시간 (만료 후 폐기)" 를 공표했으나
# 본문에 "v1.5 적용 예정"이라 자인했고, 실제로 토큰은 영구 유효했다.
# 공표한 방침을 코드가 이행하도록 만든다.
RSpec.describe "IR 다운로드 토큰 만료", type: :request do
  let(:download) do
    Download.create!(name: "투자자", email: "vc@test.com", company: "VC",
                     asset: "ir_deck_ko", locale: "ko", privacy_agreed_at: Time.current)
  end

  it "발급 직후에는 다운로드된다" do
    get "/ko/ir/#{download.download_token}"
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to start_with("application/pdf")
  end

  it "24시간이 지나면 거부된다" do
    download.update_column(:token_issued_at, 25.hours.ago)
    get "/ko/ir/#{download.download_token}"
    expect(response).to redirect_to("/ko/company/investors")
  end

  it "23시간까지는 유효하다 (경계)" do
    download.update_column(:token_issued_at, 23.hours.ago)
    get "/ko/ir/#{download.download_token}"
    expect(response).to have_http_status(:ok)
  end

  # create 가 find_or_initialize_by(email:, asset:) 로 기존 레코드를 재사용한다.
  # 재신청 시 토큰 발급 시각이 갱신되지 않으면 메일을 받자마자 만료된 링크가 온다.
  it "같은 이메일로 재신청하면 만료 시각이 갱신된다" do
    download.update_column(:token_issued_at, 30.hours.ago)

    post "/ko/company/investors", params: {
      download: { name: "투자자", email: "vc@test.com", company: "VC",
                  role: "심사역", asset: "ir_deck_ko", consent: "1" }
    }

    expect(download.reload.token_issued_at).to be_within(1.minute).of(Time.current)
    get "/ko/ir/#{download.reload.download_token}"
    expect(response).to have_http_status(:ok)
  end

  it "만료된 토큰에는 안내 메시지가 나온다" do
    download.update_column(:token_issued_at, 25.hours.ago)
    get "/ko/ir/#{download.download_token}"
    follow_redirect!
    expect(response.body).to include(I18n.t("investors.errors.token_expired"))
  end
end

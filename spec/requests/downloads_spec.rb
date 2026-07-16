require "rails_helper"

RSpec.describe "IR Download flow", type: :request do
  include ActiveJob::TestHelper

  it "POST /ko/company/investors — Download 저장 + 토큰 발급 + 메일 2통(신청자 자료 + 관리자 알림)" do
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
        .and change { ActionMailer::Base.deliveries.size }.by(2)
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

# IR 신청이 오면 대표님께 알린다. 자료는 이미 자동 발송된 뒤이고,
# 이 알림의 목적은 "누가 받아갔는지" 를 놓치지 않는 것이다.
# 데모 신청·문의는 알림이 있는데 IR 만 없었다. — 2026-07-16
RSpec.describe "IR 신청 관리자 알림", type: :request do
  include ActiveJob::TestHelper

  def apply(email:, name: "신청자", company: "회사")
    perform_enqueued_jobs do
      post "/ko/company/investors", params: {
        download: { name: name, email: email, company: company,
                    role: "심사역", asset: "ir_deck_ko", consent: "1" }
      }
    end
  end

  def admin_mail
    ActionMailer::Base.deliveries.find { |m| m.to.include?("admin@ximtier.io") }
  end

  it "신청하면 관리자에게 알림이 간다" do
    apply(email: "someone@somewhere.co.kr")
    expect(admin_mail).to be_present
  end

  it "신청자에게 가는 자료 메일과는 별개다" do
    apply(email: "someone@somewhere.co.kr")
    expect(ActionMailer::Base.deliveries.map(&:to).flatten)
      .to include("someone@somewhere.co.kr", "admin@ximtier.io")
  end

  describe "제목만 보고 우선순위를 알 수 있다" do
    it "VC 도메인이면 제목에 표시된다" do
      apply(email: "partner@theventures.co.kr", name: "이수정", company: "더벤처스")
      expect(admin_mail.subject).to include("VC")
      expect(admin_mail.subject).to include("이수정")
    end

    it "무료메일이면 미판별로 표시된다" do
      apply(email: "someone@gmail.com")
      expect(admin_mail.subject).to include("미판별")
    end

    it "회사 도메인이면 법인으로 표시된다" do
      apply(email: "exec@hyundai-sme.com")
      expect(admin_mail.subject).to include("법인")
    end
  end

  it "신청 기록에 분류가 저장된다" do
    apply(email: "partner@theventures.co.kr")
    expect(Download.find_by(email: "partner@theventures.co.kr").investor_kind).to eq("vc")
  end

  it "알림 본문에 판단에 필요한 정보가 담긴다" do
    apply(email: "partner@theventures.co.kr", name: "이수정", company: "더벤처스")
    text = admin_mail.text_part ? admin_mail.text_part.body.decoded : admin_mail.body.decoded

    expect(text).to include("이수정")
    expect(text).to include("더벤처스")
    expect(text).to include("partner@theventures.co.kr")
    expect(text).not_to include("translation missing")
  end
end

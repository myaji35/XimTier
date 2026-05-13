require "rails_helper"

# 캐릭터 저니 5종 — request-level 자동화 (CI 무겁지 않은 핵심 단계만)
# 풀 브라우저 자동화는 별도 system spec/Playwright job에서 처리.
RSpec.describe "Character Journeys", type: :request do
  include ActiveJob::TestHelper

  # === 1. 김상무 (제조 SME, 한글) ===
  describe "1. 김상무 — 제조 SME (한글)" do
    it "Hero → use-cases → 케이스스터디 → 데모 신청 → 대시보드" do
      # Step 1: Accept-Language ko → /ko 리디렉트
      get "/", headers: { "Accept-Language" => "ko-KR,ko;q=0.9" }
      expect(response).to redirect_to("/ko")

      # Step 2: Hero 메시지
      get "/ko"
      expect(response.body).to include("감사를 통과할 수 없습니다")

      # Step 3: use-cases 클릭
      get "/ko/use-cases"
      expect(response.body).to include("제조")

      # Step 4: 제조 케이스스터디
      get "/ko/cases/manufacturing"
      expect(response.body).to include("반도체 공정")
      expect(response.body).to include("불량률")

      # Step 5: 데모 신청 폼
      get "/ko/demo"
      expect(response).to have_http_status(:ok)

      # Step 6: 데모 신청 제출
      perform_enqueued_jobs do
        post "/ko/demo", params: {
          demo_request: {
            name: "김상무", email: "kim-journey@test.com", company: "제조 SME",
            role: "제조본부장", industry: "manufacturing",
            data_description: "공정 로그 분석", consent: "1"
          }
        }
      end
      expect(response).to redirect_to("/ko/dashboard")

      # Step 7: 대시보드
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("김상무")
    end
  end

  # === 2. 박사무관 (공공, 한글) ===
  describe "2. 박사무관 — 공공기관 (한글)" do
    it "use-cases → 공공 케이스 → 문의 폼 제출" do
      get "/ko/use-cases"
      expect(response.body).to include("공공")

      get "/ko/cases/public"
      expect(response.body).to include("정책 시나리오")

      get "/ko/contact"
      expect(response).to have_http_status(:ok)

      perform_enqueued_jobs do
        post "/ko/contact", params: {
          contact_inquiry: {
            name: "박사무관", email: "park-journey@test.com", company: "광역시청",
            industry: "public_sector",
            message: "청년 실업률 정책 시뮬레이션 데모 가능한지",
            consent: "1"
          }
        }
      end
      expect(response).to redirect_to("/ko/contact")
      expect(ContactInquiry.last.industry).to eq("public_sector")
    end
  end

  # === 3. Sarah (영문 개발자) ===
  describe "3. Sarah — Anthropic MCP developer (English)" do
    it "EN landing → Platform API → KO/EN toggle" do
      get "/", headers: { "Accept-Language" => "en-US,en;q=0.9" }
      expect(response).to redirect_to("/en")

      get "/en"
      expect(response.body).to include("pass audit")
      expect(response.body).to include("Reverse What-If")

      get "/en/platform-api"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MCP")

      # 토글 검증
      get "/ko"
      expect(response.body).to include("감사를 통과할 수 없습니다")
    end
  end

  # === 4. Investor (Pre-Seed VC) ===
  describe "4. Investor — Pre-Seed VC" do
    it "investors 페이지 → IR 다운로드 폼 → 토큰 → PDF" do
      get "/ko/company/investors"
      expect(response.body).to include("Pre-Seed")

      perform_enqueued_jobs do
        post "/ko/company/investors", params: {
          download: {
            name: "투자자", email: "vc-journey@test.com",
            company: "더벤처스", role: "심사역", asset: "ir_deck_ko"
          }
        }
      end
      expect(response).to redirect_to(/sent=1/)

      d = Download.last
      expect(d.download_token).to be_present

      # 토큰 URL → PDF
      get "/ko/ir/#{d.download_token}"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to start_with("application/pdf")
    end

    it "시장 페이지 → $81B 근거 확인" do
      get "/ko/company/market"
      expect(response.body).to include("$81B")
      expect(response.body).to include("MarketsandMarkets")
    end
  end

  # === 5. Admin (운영팀) ===
  describe "5. Admin — 운영팀" do
    let(:admin_user) { User.create!(email: "admin-journey@test.com", password: "secret123!", admin: true, name: "Admin", locale: "ko") }
    let(:non_admin)  { User.create!(email: "user-journey@test.com",  password: "secret123!", name: "User",  locale: "ko") }

    it "/admin 비로그인 → sign_in 리디렉트" do
      get "/admin"
      expect([302, 401]).to include(response.status)
    end

    it "/admin 일반유저 로그인 → sign_in 리디렉트 (admin? 게이트)" do
      sign_in non_admin
      get "/admin"
      expect([302, 401, 403]).to include(response.status)
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

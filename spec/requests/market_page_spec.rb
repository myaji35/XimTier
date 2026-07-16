require "rails_helper"

RSpec.describe "Market page", type: :request do
  it "/ko/company/market — 200 + 핵심 카피" do
    get "/ko/company/market"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("$81B")
    expect(response.body).to include("$50.1B")
    expect(response.body).to include("$36.3B")
    expect(response.body).to include("합산 모델로 검증")
    expect(response.body).to include('data-controller="market-scenario"')
  end

  it "/en/company/market — 200 + 영문 카피" do
    get "/en/company/market"
    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/sum-of-adjacent/i)
    expect(response.body).to include("$81B")
    expect(response.body).to match(/Bull TAM/)
  end

  it "출처 8개 카드 노출" do
    get "/ko/company/market"
    expect(response.body).to include("MarketsandMarkets")
    expect(response.body).to include("Grand View Research")
    expect(response.body).to include("Gartner")
    expect(response.body).to include("EU Commission")
    expect(response.body).to include("Statista")
  end

  # 시장($81B TAM) 자료는 투자자용이다. v3 개편에서 고객용 랜딩·헤더 메뉴와 분리했고,
  # 진입 경로를 IR(investors) 쪽으로 일원화했다 (2026-07-16 결정).
  # 홈/헤더에 링크를 기대하던 옛 테스트는 그 결정에 맞게 교체한다.
  describe "진입 경로 — 투자자 경로로 일원화" do
    it "Investors 페이지에서 시장 페이지로 갈 수 있다" do
      get "/ko/company/investors"
      expect(response.body).to match(%r{/ko/company/market})
      expect(response.body).to include("합산 근거")
    end

    it "영문 Investors 페이지에서도 갈 수 있다" do
      get "/en/company/investors"
      expect(response.body).to match(%r{/en/company/market})
    end

    # 고객용 헤더 메뉴는 제품 기능(개요·데이터·분석·솔루션·활용·사례)만 노출한다.
    # 투자 유치 자료가 섞이지 않도록 의도적으로 제외한 상태를 고정한다.
    it "고객용 헤더 메뉴에는 시장 링크가 없다" do
      get "/ko"
      expect(response.body).not_to include(">시장</a>")
    end
  end
end

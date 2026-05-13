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

  it "홈에서 '근거 보기' 링크 노출" do
    get "/ko"
    expect(response.body).to match(%r{/ko/company/market})
    expect(response.body).to include("근거 보기")
  end

  it "Investors 페이지에 시장 페이지 링크 노출" do
    get "/ko/company/investors"
    expect(response.body).to match(%r{/ko/company/market})
    expect(response.body).to include("합산 근거")
  end

  it "Nav 메뉴에 '시장' 추가" do
    get "/ko"
    expect(response.body).to include(">시장</a>") .or include(">시장<")
  end
end

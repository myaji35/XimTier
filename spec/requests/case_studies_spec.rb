require "rails_helper"

RSpec.describe "Case Studies", type: :request do
  CASES = {
    "manufacturing" => { ko: "반도체 공정",        en: "Semiconductor" },
    "hospital"      => { ko: "XAI 진단 보조",      en: "XAI diagnostic" },
    "public"        => { ko: "정책 시나리오",      en: "policy simulation" },
    "smart-city"    => { ko: "교통·에너지",       en: "traffic" },
    "finance"       => { ko: "Adverse Action",   en: "adverse action" },
    "retail"        => { ko: "프로모션 ROI",       en: "promotion ROI" },
    "logistics"     => { ko: "라스트마일",          en: "Last-mile" },
    "energy"        => { ko: "첨두 부하",          en: "peak" },
    "education"     => { ko: "중도이탈",            en: "dropout" },
    "telecom"       => { ko: "이탈 예측",          en: "churn" }
  }.freeze

  CASES.each do |slug, snip|
    it "/ko/cases/#{slug} — 200 + 핵심 카피" do
      get "/ko/cases/#{slug}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(snip[:ko])
    end

    it "/en/cases/#{slug} — 200 + 영문 카피" do
      get "/en/cases/#{slug}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(snip[:en])
    end
  end

  it "/ko/cases/invalid — 404" do
    expect {
      get "/ko/cases/invalid-industry"
    }.to raise_error(ActionController::RoutingError).or change { response&.status }.to(404)
  rescue ActionController::RoutingError
    # 라우트 제약(constraints)으로 404 또는 RoutingError 발생
    expect(true).to be true
  end

  it "use_cases 페이지에서 10 케이스스터디 링크 모두 노출" do
    get "/ko/use-cases"
    %w[manufacturing hospital public smart-city finance retail logistics energy education telecom].each do |slug|
      expect(response.body).to match(%r{/ko/cases/#{slug}}), "missing /ko/cases/#{slug} link"
    end
  end

  it "Pricing 매트릭스 노출" do
    get "/ko/pricing"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("FEATURE MATRIX")
    expect(response.body).to include("기능 비교 매트릭스")
  end

  it "Hero CTA 라우팅 — /demo, /investors 정상 path" do
    get "/ko"
    expect(response.body).to match(%r{href="/ko/demo"})
    expect(response.body).to match(%r{href="/ko/company/investors"})
  end

  it "Tweaks Panel 마운트" do
    get "/ko"
    expect(response.body).to include('data-controller="tweaks"')
    expect(response.body).to include("Designer's preview")
  end
end

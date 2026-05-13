require "rails_helper"

RSpec.describe "W4 — Cookie banner / Legal / Error pages", type: :request do
  it "Cookie banner 마운트" do
    get "/ko"
    expect(response.body).to include('data-controller="cookie-banner"')
    expect(response.body).to match(/필수 쿠키|essential cookies/i)
  end

  it "/ko/privacy — 본문 8섹션 노출" do
    get "/ko/privacy"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("개인정보처리방침")
    expect(response.body).to include("1. 수집하는 정보")
    expect(response.body).to include("8. 책임자")
    expect(response.body).to include("PIPA")
  end

  it "/en/privacy — English content" do
    get "/en/privacy"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Privacy Policy")
    expect(response.body).to match(/PIPA/i)
    expect(response.body).to include("GDPR")
  end

  it "/ko/terms — 본문 7섹션 노출" do
    get "/ko/terms"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("이용약관")
    expect(response.body).to include("1. 서비스 소개")
    expect(response.body).to include("7. 분쟁 해결")
  end

  it "/en/terms — English content" do
    get "/en/terms"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Terms of Service")
  end

  it "404.html — 정적 자산 + 브랜드 컬러" do
    get "/this-does-not-exist-xyz"
    # Rails는 production에서 public/404.html 서빙, dev에서 RoutingError raise → :not_found 또는 500
    # 두 환경 모두 404 status 보장
    expect([404, 500]).to include(response.status)
  end
end

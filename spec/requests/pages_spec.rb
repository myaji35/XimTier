require "rails_helper"

RSpec.describe "Pages", type: :request do
  PUBLIC_PAGES = {
    ""               => { ko: "감사를 통과할 수 없습니다",     en: "pass audit" },
    "/problem"       => { ko: "데이터 주권",                en: "Data Sovereignty" },
    "/solution"      => { ko: "결합하면 완성된다",          en: "together they" }, # apostrophe → &#39; 이스케이프 회피
    "/how-it-works"  => { ko: "5단계",                      en: "5-Step" },
    "/use-cases"     => { ko: "제조",                       en: "Manufacturing" },
    "/why-not-llm"   => { ko: "ChatGPT는 설명",             en: "ChatGPT explains" },
    "/pricing"       => { ko: "Light SaaS",                en: "Light SaaS" },
    "/platform-api"  => { ko: "MCP Server",                en: "MCP Server" },
    "/company/team"  => { ko: "한일",                       en: "Han Il" },
    "/company/vision" => { ko: "3단계 플랫폼",             en: "Three-phase" },
    "/company/investors" => { ko: "Pre-Seed",              en: "Pre-Seed" },
    "/contact"       => { ko: "문의",                       en: "inquiries" },
    "/demo"          => { ko: "데모",                       en: "Demo" }
  }.freeze

  describe "GET /" do
    it "Accept-Language: ko -> /ko" do
      get "/", headers: { "Accept-Language" => "ko-KR,ko;q=0.9" }
      expect(response).to redirect_to("/ko")
    end

    it "Accept-Language: en -> /en" do
      get "/", headers: { "Accept-Language" => "en-US,en;q=0.9" }
      expect(response).to redirect_to("/en")
    end
  end

  describe "GET /up (health)" do
    it "Kamal health check 200" do
      get "/up"
      expect(response).to have_http_status(:ok)
    end
  end

  PUBLIC_PAGES.each do |path, snippet|
    describe "GET /ko#{path}" do
      it "한국어 페이지 200 + 핵심 카피 출력" do
        get "/ko#{path}"
        expect(response).to have_http_status(:ok), "Failed: /ko#{path} returned #{response.status}"
        expect(response.body).to include(snippet[:ko]),
          "Expected /ko#{path} to include '#{snippet[:ko]}'"
      end
    end

    describe "GET /en#{path}" do
      it "영문 페이지 200 + 핵심 카피 출력" do
        get "/en#{path}"
        expect(response).to have_http_status(:ok), "Failed: /en#{path} returned #{response.status}"
        expect(response.body).to include(snippet[:en]),
          "Expected /en#{path} to include '#{snippet[:en]}'"
      end
    end
  end

  describe "Layout — brand + i18n + hreflang" do
    it "hreflang ko/en/x-default 노출" do
      get "/ko"
      expect(response.body).to match(/hreflang=["']ko["']/)
      expect(response.body).to match(/hreflang=["']en["']/)
      expect(response.body).to match(/hreflang=["']x-default["']/)
    end

    it "XimTier 브랜드명 표시 (회사/도메인)" do
      get "/ko"
      expect(response.body).to include("XimTier")
    end
  end
end

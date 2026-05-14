require "rails_helper"

RSpec.describe "SEO assets", type: :request do
  it "robots.txt 200 + 핵심 룰" do
    get "/robots.txt"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("User-agent: *")
    expect(response.body).to include("Disallow: /admin")
    expect(response.body).to include("Disallow: /users")
    expect(response.body).to include("Disallow: /ir/")
    expect(response.body).to include("Sitemap:")
  end

  it "og-image.png 자산 200" do
    get "/og-image.png"
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to start_with("image/")
  end

  it "/ko HTML — Organization JSON-LD 노출" do
    get "/ko"
    expect(response.body).to include('application/ld+json')
    expect(response.body).to include('"Organization"')
    expect(response.body).to include('"XimTier"')
  end

  it "/ko HTML — WebSite JSON-LD 노출" do
    get "/ko"
    expect(response.body).to include('"WebSite"')
  end

  it "/ko HTML — OG meta image 노출" do
    get "/ko"
    expect(response.body).to match(/property=["']og:image["']/)
    expect(response.body).to include("og-image.png")
  end

  it "/ko/cases/manufacturing — Article JSON-LD 노출" do
    get "/ko/cases/manufacturing"
    expect(response.body).to include('"Article"')
    expect(response.body).to include('"headline"')
  end

  it "hreflang ko/en 노출" do
    get "/ko"
    expect(response.body).to match(/hreflang=["']ko["']/)
    expect(response.body).to match(/hreflang=["']en["']/)
  end

  it "hreflang — 현재 경로를 보존 (서브 페이지)" do
    get "/ko/pricing"
    expect(response.body).to match(%r{hreflang=["']en["']\s+href=["'][^"']*/en/pricing})
    expect(response.body).to match(%r{hreflang=["']ko["']\s+href=["'][^"']*/ko/pricing})
    expect(response.body).to match(%r{hreflang=["']x-default["']\s+href=["'][^"']*/pricing})
  end

  it "/ko/how-it-works — FAQPage JSON-LD + 가시 FAQ 노출" do
    get "/ko/how-it-works"
    expect(response.body).to include('"FAQPage"')
    expect(response.body).to include('"mainEntity"')
    # 시각적 FAQ 마크업도 함께
    expect(response.body).to include('itemtype="https://schema.org/FAQPage"')
  end

  it "canonical link이 현재 URL을 가리킨다" do
    get "/ko/pricing"
    expect(response.body).to match(%r{<link rel=["']canonical["']\s+href=["'][^"']*/ko/pricing})
  end

  it "per-page description meta가 page-specific 값으로 노출 (how_it_works)" do
    get "/ko/how-it-works"
    expect(response.body).to match(/name=["']description["'][^>]*Reverse What-If/)
  end

  it "sitemap.xml.gz가 생성되어 있고 양/영 URL을 모두 포함" do
    path = Rails.root.join("public", "sitemap.xml.gz")
    expect(path).to exist
    require "zlib"
    body = Zlib::GzipReader.open(path) { |gz| gz.read }
    expect(body).to include("<urlset")
    expect(body).to include("/ko/how-it-works")
    expect(body).to include("/en/how-it-works")
    expect(body).to include('hreflang="x-default"')
    # 깨진 더블 슬래시 회귀 방지
    expect(body).not_to match(%r{href="//[a-z]})
  end
end

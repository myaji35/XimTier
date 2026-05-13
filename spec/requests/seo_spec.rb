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
end

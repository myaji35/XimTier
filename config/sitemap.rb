# sitemap_generator 설정 — XimTier
# 빌드: bundle exec rake sitemap:refresh:no_ping

SitemapGenerator::Sitemap.default_host = ENV.fetch("SITEMAP_HOST", "https://xaisimtier.example.com")

PUBLIC_PAGES = %w[
  /
  /problem
  /solution
  /how-it-works
  /use-cases
  /pricing
  /platform-api
  /company/team
  /company/vision
  /company/investors
  /contact
  /demo
  /privacy
  /terms
].freeze

SitemapGenerator::Sitemap.create do
  %i[ko en].each do |locale|
    PUBLIC_PAGES.each do |path|
      url = path == "/" ? "/#{locale}" : "/#{locale}#{path}"
      priority = path == "/" ? 1.0 : 0.8
      changefreq = path == "/" ? "weekly" : "monthly"
      add(url, priority: priority, changefreq: changefreq,
          alternates: [
            { href: "/ko#{path == '/' ? '' : path}", lang: "ko" },
            { href: "/en#{path == '/' ? '' : path}", lang: "en" },
            { href: "/#{path == '/' ? '' : path}",    lang: "x-default" }
          ])
    end
  end
end

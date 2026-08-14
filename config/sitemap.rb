# sitemap_generator 설정 — XimTier
# 빌드: bundle exec rake sitemap:refresh:no_ping

SitemapGenerator::Sitemap.default_host =
  if ENV["APP_HOST"].present?
    "#{ENV.fetch('APP_PROTOCOL', 'https')}://#{ENV['APP_HOST']}"
  else
    "https://ximtier.com"
  end
SITEMAP_HOST = SitemapGenerator::Sitemap.default_host

# 우선순위 1.0: 핵심 컨버전, 0.8: 정보, 0.6: 법적
PUBLIC_PAGES = [
  { path: "/",                     priority: 1.0, changefreq: "weekly" },
  { path: "/problem",              priority: 0.8, changefreq: "monthly" },
  { path: "/solution",             priority: 0.8, changefreq: "monthly" },
  { path: "/how-it-works",         priority: 0.9, changefreq: "monthly" },
  { path: "/why-not-llm",          priority: 0.9, changefreq: "monthly" },
  { path: "/use-cases",            priority: 0.8, changefreq: "monthly" },
  { path: "/cases/manufacturing",  priority: 0.7, changefreq: "monthly" },
  { path: "/cases/hospital",       priority: 0.7, changefreq: "monthly" },
  { path: "/cases/public",         priority: 0.7, changefreq: "monthly" },
  { path: "/cases/smart-city",     priority: 0.7, changefreq: "monthly" },
  { path: "/cases/ga-branch",      priority: 0.7, changefreq: "monthly" },
  { path: "/pricing",              priority: 0.8, changefreq: "monthly" },
  { path: "/platform-api",         priority: 0.7, changefreq: "monthly" },
  { path: "/v3/overview",          priority: 0.7, changefreq: "monthly" },
  { path: "/v3/data",              priority: 0.7, changefreq: "monthly" },
  { path: "/v3/analysis",          priority: 0.7, changefreq: "monthly" },
  { path: "/v3/solutions",         priority: 0.7, changefreq: "monthly" },
  { path: "/v3/usage",             priority: 0.7, changefreq: "monthly" },
  { path: "/company/team",         priority: 0.6, changefreq: "monthly" },
  { path: "/company/vision",       priority: 0.6, changefreq: "monthly" },
  { path: "/company/market",       priority: 0.7, changefreq: "monthly" },
  { path: "/company/investors",    priority: 0.5, changefreq: "monthly" },
  { path: "/contact",              priority: 0.5, changefreq: "monthly" },
  { path: "/demo",                 priority: 0.9, changefreq: "weekly" },
  { path: "/privacy",              priority: 0.3, changefreq: "yearly" },
  { path: "/terms",                priority: 0.3, changefreq: "yearly" }
].freeze

# 루트는 301 리다이렉트되므로 sitemap에 넣으면 Search Console이 색인을 거부한다.
# /ko와 /en을 명시 등록하고 x-default로 루트를 가리키는 것으로 충분하다. (ISS-215)
SitemapGenerator::Sitemap.create(include_root: false) do
  %i[ko en].each do |locale|
    PUBLIC_PAGES.each do |entry|
      is_root = entry[:path] == "/"
      url = is_root ? "/#{locale}" : "/#{locale}#{entry[:path]}"
      add(url, priority: entry[:priority], changefreq: entry[:changefreq],
          alternates: [
            { href: "#{SITEMAP_HOST}/ko#{is_root ? '' : entry[:path]}", lang: "ko" },
            { href: "#{SITEMAP_HOST}/en#{is_root ? '' : entry[:path]}", lang: "en" },
            { href: is_root ? SITEMAP_HOST : "#{SITEMAP_HOST}#{entry[:path]}", lang: "x-default" }
          ])
    end

    add("/#{locale}/cases", priority: 0.7, changefreq: "weekly",
        alternates: [
          { href: "#{SITEMAP_HOST}/ko/cases", lang: "ko" },
          { href: "#{SITEMAP_HOST}/en/cases", lang: "en" },
          { href: "#{SITEMAP_HOST}/cases",    lang: "x-default" }
        ])

    CaseStudy.published.find_each do |cs|
      path = "/cases/#{cs.slug}/gallery"
      add("/#{locale}#{path}", priority: 0.6, changefreq: "monthly", lastmod: cs.updated_at,
          alternates: [
            { href: "#{SITEMAP_HOST}/ko#{path}", lang: "ko" },
            { href: "#{SITEMAP_HOST}/en#{path}", lang: "en" },
            { href: "#{SITEMAP_HOST}#{path}",    lang: "x-default" }
          ])
    end
  end
end

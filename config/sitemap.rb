# sitemap_generator 설정 — XimTier
# 빌드: bundle exec rake sitemap:refresh:no_ping

SitemapGenerator::Sitemap.default_host =
  if ENV["APP_HOST"].present?
    "#{ENV.fetch('APP_PROTOCOL', 'https')}://#{ENV['APP_HOST']}"
  else
    "https://ximtier.io"
  end

# 우선순위 1.0: 핵심 컨버전, 0.8: 정보, 0.6: 법적
PUBLIC_PAGES = [
  { path: "/",                     priority: 1.0, changefreq: "weekly" },
  { path: "/problem",              priority: 0.8, changefreq: "monthly" },
  { path: "/solution",             priority: 0.8, changefreq: "monthly" },
  { path: "/how-it-works",         priority: 0.9, changefreq: "monthly" },
  { path: "/use-cases",            priority: 0.8, changefreq: "monthly" },
  { path: "/cases/manufacturing",  priority: 0.7, changefreq: "monthly" },
  { path: "/cases/hospital",       priority: 0.7, changefreq: "monthly" },
  { path: "/cases/public",         priority: 0.7, changefreq: "monthly" },
  { path: "/cases/smart-city",     priority: 0.7, changefreq: "monthly" },
  { path: "/pricing",              priority: 0.8, changefreq: "monthly" },
  { path: "/platform-api",         priority: 0.7, changefreq: "monthly" },
  { path: "/company/team",         priority: 0.6, changefreq: "monthly" },
  { path: "/company/vision",       priority: 0.6, changefreq: "monthly" },
  { path: "/company/market",       priority: 0.7, changefreq: "monthly" },
  { path: "/company/investors",    priority: 0.5, changefreq: "monthly" },
  { path: "/contact",              priority: 0.5, changefreq: "monthly" },
  { path: "/demo",                 priority: 0.9, changefreq: "weekly" },
  { path: "/privacy",              priority: 0.3, changefreq: "yearly" },
  { path: "/terms",                priority: 0.3, changefreq: "yearly" }
].freeze

SitemapGenerator::Sitemap.create do
  %i[ko en].each do |locale|
    PUBLIC_PAGES.each do |entry|
      is_root = entry[:path] == "/"
      url = is_root ? "/#{locale}" : "/#{locale}#{entry[:path]}"
      x_default_path = is_root ? "/" : entry[:path]
      add(url, priority: entry[:priority], changefreq: entry[:changefreq],
          alternates: [
            { href: "/ko#{is_root ? '' : entry[:path]}", lang: "ko" },
            { href: "/en#{is_root ? '' : entry[:path]}", lang: "en" },
            { href: x_default_path,                       lang: "x-default" }
          ])
    end
  end
end

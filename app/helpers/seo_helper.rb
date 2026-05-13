module SeoHelper
  # 전역 Organization JSON-LD (모든 페이지 layout에 삽입)
  def organization_jsonld
    host = ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io")
    proto = ENV.fetch("APP_PROTOCOL", "http")
    url = "#{proto}://#{host}"
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "XimTier",
      "url" => url,
      "logo" => "#{url}/icon.svg",
      "description" => t("site.positioning"),
      "founder" => [
        { "@type" => "Person", "name" => "한일", "jobTitle" => "CEO" },
        { "@type" => "Person", "name" => "강승식", "jobTitle" => "CTO" }
      ],
      "sameAs" => [
        # GitHub / LinkedIn 등 — 결정 시 추가
      ].compact,
      "knowsAbout" => [
        "Decision Intelligence",
        "Explainable AI",
        "Reverse What-If",
        "Prescriptive Analytics",
        "Post-LLM"
      ]
    }
  end

  # WebSite JSON-LD (검색 박스 노출 옵션)
  def website_jsonld
    host = ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io")
    proto = ENV.fetch("APP_PROTOCOL", "http")
    {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => "XimTier",
      "url" => "#{proto}://#{host}",
      "inLanguage" => I18n.locale.to_s
    }
  end

  # FAQPage JSON-LD (/how-it-works 같은 페이지)
  def faqpage_jsonld(qas)
    {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => qas.map { |q, a|
        {
          "@type" => "Question",
          "name" => q,
          "acceptedAnswer" => { "@type" => "Answer", "text" => a }
        }
      }
    }
  end

  # Article JSON-LD (케이스스터디용)
  def article_jsonld(title:, description:, url: request.original_url)
    host = ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io")
    proto = ENV.fetch("APP_PROTOCOL", "http")
    {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => title,
      "description" => description,
      "url" => url,
      "publisher" => {
        "@type" => "Organization",
        "name" => "XimTier",
        "logo" => { "@type" => "ImageObject", "url" => "#{proto}://#{host}/icon.svg" }
      },
      "inLanguage" => I18n.locale.to_s,
      "datePublished" => "2026-05-13"
    }
  end

  def jsonld_script(data)
    content_tag :script, raw(data.to_json), type: "application/ld+json"
  end
end

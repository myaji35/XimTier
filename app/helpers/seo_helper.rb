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
        # 확인된 공개 채널 없음 — 링크드인/깃허브 개설 시 추가
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

  # SoftwareApplication JSON-LD (제품 엔티티를 모든 페이지에서 일관되게 제공)
  def software_application_jsonld
    host = ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io")
    proto = ENV.fetch("APP_PROTOCOL", "http")
    url = "#{proto}://#{host}"
    {
      "@context" => "https://schema.org",
      "@type" => "SoftwareApplication",
      "name" => "XimTier",
      "applicationCategory" => "BusinessApplication",
      "applicationSubCategory" => "Explainable AI / Decision Intelligence",
      "operatingSystem" => "Web-based, On-premise deployment",
      "description" => "XimTier는 제조·의료·금융·공공 산업의 현업 의사결정자를 위해 Reverse What-If, SHAP 기반 수학적 설명, 100% 온프레미스 배포를 제공하는 Post-LLM Decision Intelligence 제품입니다.",
      "featureList" => [
        "Reverse What-If — 목표값에서 필요한 변수 조합 역산",
        "SHAP 기반 수학적 근거 자동 첨부",
        "100% 온프레미스 배포",
        "5단계 One-Stop 워크플로우 — 데이터 탐색 → 통계 분석 → Reverse What-If → 자동 보고서 → AI Q&A"
      ],
      "offers" => {
        "@type" => "Offer",
        "availability" => "https://schema.org/InStock",
        "url" => "#{url}/#{I18n.locale}/pricing"
      },
      "inLanguage" => I18n.locale.to_s,
      "url" => url
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

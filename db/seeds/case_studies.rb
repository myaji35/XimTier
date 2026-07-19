# 사례·홍보 콘텐츠 갤러리 예시 시드 (멱등) — bin/rails db:seed
# 운영자가 Avo(/admin)에서 실제 콘텐츠로 교체·확장하는 출발점.

examples = [
  {
    slug: "semiconductor-defect-reverse",
    title_ko: "반도체 공정 불량률 2.4% → 1.2% 역산 사례",
    title_en: "Semiconductor Defect Rate: Reverse What-If from 2.4% to 1.2%",
    industry: "제조",
    summary_ko: "온프레미스 환경에서 Reverse What-If로 목표 불량률 달성 변수값을 역산한 실제 활용 사례입니다.",
    summary_en: "A real-world case of reverse-engineering the variable values needed to hit a target defect rate, fully on-premise.",
    body_html_ko: "<p>기존 BI 도구는 회귀 결과만 보여줄 뿐, <strong>어떤 변수를 얼마나 조절해야 하는지</strong>는 답하지 못했습니다. XimTier는 SHAP 근거와 함께 변수별 최적값을 제시합니다.</p>",
    published: true,
    media: [
      { kind: :youtube, title: "제품 데모 영상", youtube_url: "https://www.youtube.com/watch?v=aqz-KE-bpKQ", position: 1,
        caption: "영상은 예시 링크입니다. Avo에서 실제 영상 URL로 교체하세요." },
      { kind: :html, title: "핵심 요약", position: 2,
        embed_html: "<ul><li>목표 불량률: 1.2%</li><li>식별 핵심 변수: 5개</li><li>EU AI Act 대응: SHAP 근거 자동 첨부</li></ul>" }
    ]
  },
  {
    slug: "public-policy-simulation",
    title_ko: "공공정책 시뮬레이션 — 예산 배분 최적화",
    title_en: "Public Policy Simulation — Budget Allocation Optimization",
    industry: "공공",
    summary_ko: "정책 목표 지표를 입력하면 예산 배분안을 역산해 제시한 공공기관 협업 사례입니다.",
    summary_en: "A public-sector collaboration where target policy metrics drive a reverse-engineered budget allocation.",
    body_html_ko: "<p>정량 목표에서 출발해 <strong>실행 가능한 배분안</strong>을 도출하고, 각 항목의 기여도를 투명하게 제시했습니다.</p>",
    published: true,
    media: [
      { kind: :html, title: "접근 방식", position: 1,
        embed_html: "<p>데이터 로딩 → 핵심 변수 식별 → Reverse What-If 역산 → 근거 리포트 자동 생성</p>" }
    ]
  },
  {
    slug: "ximtier-pitchdeck",
    title_ko: "XimTier 소개 — 제품·비전 피치덱",
    title_en: "XimTier Introduction — Product & Vision Pitch Deck",
    industry: "소개",
    summary_ko: "역방향 What-If 의사결정 인텔리전스 XimTier의 제품·시장·비전을 담은 소개 자료입니다.",
    summary_en: "An introduction to XimTier's product, market, and vision for reverse What-If decision intelligence.",
    published: true,
    media: [
      { kind: :pdf, title: "피치덱 (PDF)", position: 1,
        pdf_path: "db/seeds/assets/ximtier-pitchdeck-v2.pdf", caption: "XimTier 제품·비전 피치덱" }
    ]
  },
  {
    slug: "ximtier-decision-engine",
    title_ko: "XimTier AI 의사결정 엔진 — 기술 설명서",
    title_en: "XimTier AI Decision Engine — Technical Brief",
    industry: "기술",
    summary_ko: "SHAP 근거 기반 Reverse What-If 엔진의 작동 원리와 EU AI Act 대응 구조를 설명하는 기술 자료입니다.",
    summary_en: "A technical brief explaining how the SHAP-grounded Reverse What-If engine works and how its architecture supports EU AI Act compliance.",
    published: true,
    media: [
      { kind: :pdf, title: "기술 설명서 (PDF)", position: 1,
        pdf_path: "db/seeds/assets/ximtier-ai-decision-engine.pdf", caption: "AI 의사결정 엔진 기술 브리프" }
    ]
  }
]

examples.each do |attrs|
  media = attrs.delete(:media)
  cs = CaseStudy.find_or_initialize_by(slug: attrs[:slug])
  cs.assign_attributes(attrs)
  cs.save!
  media.each do |m|
    medium = cs.case_media.find_or_initialize_by(title: m[:title])
    pdf_path = m.delete(:pdf_path)
    medium.assign_attributes(m)
    if pdf_path && !medium.pdf.attached?
      path = Rails.root.join(pdf_path)
      medium.pdf.attach(
        io: File.open(path),
        filename: File.basename(path),
        content_type: "application/pdf"
      )
    end
    medium.save!
  end
  puts "  seeded case: #{cs.slug} (media: #{cs.case_media.count})"
end

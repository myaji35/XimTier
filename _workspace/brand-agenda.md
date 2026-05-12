# XimTier 브랜드 프로젝트 — 아젠다 분석

> 대상: `brand-dna.json` v0.2.0 + `_design_ref/design.md`
> 작성: 2026-05-12 / CTO

---

## 1. 현재 상태 진단 (As-Is)

### 1.1 자료 구성
| 자료 | 위치 | 상태 |
|---|---|---|
| `brand-dna.json` v0.2.0 | `xaisimtier/brand-dna.json` | active, design.md 1차 적용 |
| `design.md` | `_design_ref/design.md` | 외부에서 받은 시안 명세 (9KB, 234줄) |
| HTML 시안 | `_design_ref/XimTier Homepage.html` | 35KB, 정적 + 인라인 React |
| 데모 React | `_design_ref/demo.jsx` (Reverse What-If) + `tweaks-panel.jsx` | 적용 대기 |
| 스크린샷 | `_design_ref/screenshots/hero.png` | 디자인 의도 캡처 |

### 1.2 정의된 항목 (이미 갖춰진 것)
- **브랜드 이중구조**: 회사/도메인 = XimTier, 제품/기술 = XAISimTier
- **포지셔닝**: "Decision Intelligence, Proven by Numbers"
- **태그라인**: 한 — "LLM이 못 푸는 수치를, 우리가 증명한다" / 영 — "We prove the numbers LLMs can't."
- **컬러 시스템**: Blue(`#2563EB`) + Teal(`#00C8C8`) + Deep Navy(`#0B132D`) + Light Gray(`#F2F4F7`)
- **그라디언트**: `linear-gradient(135deg, #2563EB, #00C8C8)` + X 심볼 2-blade variant
- **타이포그래피**: Pretendard(한/영 본문) + JetBrains Mono(기술 라벨/메트릭)
- **타입 스케일**: clamp 기반 6단계 (display/section/card/eyebrow/lead/body)
- **레이아웃 토큰**: max-width 1240px, gutter 32px, section-pad 120/80px
- **컴포넌트 토큰**: radius 14/18/20/999, shadow 4종, motion 3종
- **반응형**: 단일 브레이크포인트 979/980
- **섹션 톤 교차**: light → dark → light → tinted → ... (design.md §4)
- **X 심볼**: 4-blade 구조 (top: gradient, bottom: navy/white), light/dark variant SVG

### 1.3 구현된 것 (xaisimtier/ 코드 기준)
- `app/assets/tailwind/application.css` — design.md 토큰 100% 매핑 (`@theme` + presets)
- `app/components/brand_logo_component.*` — X 심볼 + Wordmark 컴포넌트
- `app/views/shared/_brand_svg_defs.html.erb` — 4-blade `<symbol>` defs (light/dark 2종)
- `app/components/moat_triangle_component.*` — 해자 삼각형 SVG (light tone, gradient center)
- `app/components/workflow_steps_component.*` — 5단계 워크플로우 인디케이터
- `app/components/{hero,section,card,cta,icon,stat_indicator}_component.*` — 7개 재사용 컴포넌트
- 한글 어절 줄바꿈 (`word-break: keep-all`) 헤딩/lead 전역 적용

---

## 2. 갭 분석 (Gaps)

### 🔴 P0 — 핵심 미구현 (브랜드 약속 미충족)

| 항목 | 이유 |
|---|---|
| **Reverse What-If 인터랙티브 데모** | `_design_ref/demo.jsx`(7.9KB)가 존재하나 Hotwire/Stimulus 미포팅. 피치덱 핵심 차별점이자 design.md §6 "핵심" 표시 — *제품을 5분 안에 보여주는* 단 하나의 비주얼이 부재 |
| **Floating data chips 애니메이션** | Hero 데이터 칩 4개(온도/SHAP/불량률/R²)가 정적 표시 중. design.md §5 "5-7s ease-in-out float, staggered" 모션 미적용 |
| **Tweaks Panel (우하단 토글)** | `tweaks-panel.jsx` 25.8KB — 섹션 톤/액센트/칩/여백 사용자 토글. UX 차별 포인트인데 미구현 |
| **brand-dna 진화 게이트** | `_status: active`까지 와 있으나 **변경 시 거버넌스가 없음**. 누가/언제 색을 바꿀지 의사결정 프로세스 부재 |

### 🟡 P1 — 일관성 갭

| 항목 | 이슈 |
|---|---|
| **Tweak 4종 옵션 미실현** | 다크 히어로 / 올라이트 / Electric(blue→purple) / Monochrome 톤 — design.md §7에 명시되지만 토큰만 존재 (정의 미반영) |
| **로고 사용 규정 부재** | "워드마크 14px·심볼 16px 최소" 규정이 design.md에만 있고 brand-dna.json `_rules` 등으로 코드화 안 됨 |
| **카피 보이스 가이드 코드화 안 됨** | "단언 톤"·"숫자 먼저"·"금지어(혁신적/최첨단)" 같은 규칙이 i18n YAML 검수 도구로 강제되지 않음 (lint 부재) |
| **카피라이팅 영문 1차 번역만** | en YAML이 LLM 1차 번역 — 네이티브 카피라이터 검수 미진행 (PRD M2 리스크 항목) |
| **다크↔라이트 섹션 전환 규칙 부재** | "연속된 같은 톤 금지" (design.md §4)가 컴포넌트 레벨 가드로 없음 |

### 🟢 P2 — 확장/스케일 갭

| 항목 | 이슈 |
|---|---|
| **Open Graph 이미지 자산** | `og:image` 정의/렌더 누락. 트위터 카드 빈 상태 |
| **favicon/icon 시스템** | Rails 기본 default. X 심볼 기반 favicon 16/32/180px PNG + SVG 미생성 |
| **다국어 확장(JP/VN)** | design.md §11에 "동남아 진출 시 JP/VN" 명시. 폰트 fallback 점검 안 됨 |
| **Pricing/Investor PDF 디자인 통합** | 피치덱 PDF는 별도 자료 — 브랜드 시스템과 시각 통일성 검수 안 됨 |
| **Email 템플릿 디자인** | Action Mailer HTML 템플릿이 디자인 토큰을 못 받음 (인라인 CSS 필요, brand-dna에서 자동 생성 헬퍼 부재) |
| **Avo Admin 브랜딩** | `/admin` 영역이 Avo 기본 테마. XimTier 토큰 미주입 (`config.branding`) |

---

## 3. 우선순위별 액션 아젠다

### Sprint Brand-A (1주, P0)
- [ ] **A1**: `demo.jsx` → Stimulus 컨트롤러 포팅 (Reverse What-If 슬라이더 + SHAP 탭). 클라이언트 사이드 계산, mock 데이터로 시작
- [ ] **A2**: Hero floating chips 5-7s float 애니메이션 — CSS keyframes 4개 staggered
- [ ] **A3**: Tweaks panel — 우하단 floating UI + localStorage 영속화. 4종 옵션(섹션 톤/액센트/칩/여백)
- [ ] **A4**: `brand-dna.json`에 `_governance` 섹션 추가 — owner/change_log/lock_keys 명시

### Sprint Brand-B (1주, P1)
- [ ] **B1**: Tweak 4종 컬러 액센트 토큰 정의 → `brand-dna.json.design_tokens.themes.*`로 분기
- [ ] **B2**: 카피 lint — i18n-tasks + 정규식 룰 ("혁신적|최첨단|차세대" 검출 시 CI 실패)
- [ ] **B3**: `app/components/section_component.rb`에 톤 가드 — 직전 섹션과 동일 톤이면 warning
- [ ] **B4**: 로고 사용 규정 — `BrandLogoComponent`에 min_size 가드 (size < 16일 때 raise)
- [ ] **B5**: 영문 카피 네이티브 검수 — 외부 카피라이터 발주 또는 GPT-4o + 한일 CEO 검수 루프

### Sprint Brand-C (2주, P2)
- [ ] **C1**: OG 이미지 생성 헬퍼 — Vercel OG-style PNG 자동 생성 (Cloudflare Workers 또는 Rails Image Processing)
- [ ] **C2**: X 심볼 favicon 풀세트 — 16/32/180/512px PNG + SVG + manifest.json
- [ ] **C3**: Action Mailer HTML 템플릿 — `inline_css` gem + brand-dna 자동 주입 헬퍼
- [ ] **C4**: Avo Admin 브랜딩 — `config.branding.colors` + `logomark` 주입
- [ ] **C5**: 다국어 확장 준비 — JP(Noto Sans JP) / VN(Be Vietnam Pro) 폰트 fallback 등록
- [ ] **C6**: Pricing/Investor PDF 디자인 — Mermaid/LaTeX 또는 `report-pdf-builder` skill 활용

---

## 4. 거버넌스 제안 (brand-dna.json `_governance` 섹션 신설)

```json
"_governance": {
  "owner": "강승식 (CTO)",
  "design_lead": "한일 (CEO)",
  "approval_required_for": ["colors", "typography.scale", "brand.name", "brand.product", "brand.tagline_*"],
  "auto_iterable": ["radius", "shadow", "motion", "spacing", "page_priorities"],
  "review_cadence": "주 1회 (목요일)",
  "change_log_path": "_workspace/brand-changelog.md",
  "lock_until": "2026-09-30"
}
```

- **금지**: `voice` 4가지 핵심 단어, X 심볼 4-blade 구조, gradient 135deg + Blue→Teal 방향, "Decision Intelligence, Proven by Numbers" 포지셔닝
- **유동**: 보조 컬러 채도/명도, 카드 padding, motion timing, 일부 카피 표현

---

## 5. 측정 가능한 KPI

| KPI | 현재 | 목표 (Sprint A 후) |
|---|---|---|
| Lighthouse Performance (mobile) | (미측정) | ≥ 90 |
| Lighthouse SEO | (미측정) | ≥ 95 |
| LCP | (미측정) | < 2.5s |
| `font-display: swap` 적용 | ✅ Pretendard CDN | 유지 |
| 핵심 컴포넌트 재사용률 | 7/예상 12 | 12/12 |
| 한국어 어절 줄바꿈 적용률 | 100% (전역) | 유지 |
| 영문 카피 네이티브 검수 | 0% | 100% |
| Reverse What-If 데모 동작 | ❌ | ✅ |

---

## 6. 리스크 & 의사결정 포인트

| 리스크 | 발생 가능성 | 결정 필요 시점 |
|---|---|---|
| Reverse What-If 데모 알고리즘이 misleading하면 신뢰 손상 | 중 | Sprint Brand-A 시작 전: 어떤 mock 데이터·어떤 메시지를 보여줄지 CEO 사인오프 |
| Tweaks panel이 과해 *프로토타입 느낌* 줄 수 있음 | 중 | 디폴트 OFF, "Designer's preview" 라벨로 옵션화 |
| 영문 카피 톤 어색하면 글로벌 신뢰 손상 | 높 | M3 시작 전 |
| 다국어(JP/VN) 폰트 비용 | 저 | 동남아 진출 임박 시점 |
| Avo Admin 브랜딩 시간 소요 vs 가치 | 저 | 외부 노출 없으므로 P2 유지 가능 |

---

## 7. 한 줄 요약

> **현재 브랜드 시스템은 토큰·타이포·컬러·로고까지 design.md 100% 매핑 완료. 갭은 "정적 디자인 → 살아있는 제품" 전환 (Reverse What-If 데모 + Tweaks panel + 거버넌스).**
> **다음 1주는 Sprint Brand-A 4가지 P0 집중. MVP 출시와 병행.**

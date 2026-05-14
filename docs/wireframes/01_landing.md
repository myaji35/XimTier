# W1 — 랜딩 `/` (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속에 있어야 할 한 줄 |
|---|---|
| 김 상무 (제조 SME) | "LLM 입력 금지인데 이건 우리 데이터로 돌릴 수 있다" → 데모 신청 클릭 |
| Investor | "Pre-Seed인데 $81B 시장 + 4-blade 해자" → IR PDF 받기 |
| Sarah (MCP 개발자) | "MCP 생태계에서 Wolfram처럼 작동" → `/platform-api` 진입 |

**핵심 전환**: `Request Demo` (1차) + `IR Deck 받기` (2차)

---

## 2. 모바일 와이어 (360px 정본)

```
┌─────────────────────────────────────────┐
│ ☰  [X] XimTier            [KO|EN] [Demo→]│  ← sticky nav (56px)
├─────────────────────────────────────────┤
│                                          │
│  ╲   ╱   eyebrow.product (text-xs)       │
│   ╳   = Post-LLM Decision Intelligence   │  (dark hero, 그라디언트 BG)
│  ╱   ╲                                   │   #0B132D → 135deg
│                                          │   blue→teal accent
│   H1 (clamp 40-78px, line-clamp 3)       │
│   "LLM이 못 푸는 수치를,                  │
│    우리가 증명한다."                       │
│                                          │
│   LEAD (18px, 2-3줄)                      │
│   "통계·시뮬레이션·Reverse What-If로       │
│    LLM 너머의 의사결정을 풉니다."          │
│                                          │
│   [ Request Demo  → ]  ← primary CTA      │
│   [ IR Deck 받기  ↓ ]  ← secondary        │
│                                          │
│   ▾ (scroll cue)                          │
│                                          │
├─────────────────────────────────────────┤  ← section break (light)
│  SECTION 2 — 3가지 한계 (Slide 2)         │
│                                          │
│  EYEBROW: 문제 / The Problem             │
│  H2: "왜 LLM만으로 부족한가"               │
│                                          │
│  ┌─────────────────────────────────────┐ │
│  │ [icon] 환각                          │ │
│  │ ────────                              │ │
│  │ "그럴듯한 숫자가 틀린 숫자"            │ │
│  └─────────────────────────────────────┘ │
│  ┌─────────────────────────────────────┐ │
│  │ [icon] 보안                          │ │
│  │ ────────                              │ │
│  │ "기업 데이터는 외부 LLM에 못 보냄"     │ │
│  └─────────────────────────────────────┘ │
│  ┌─────────────────────────────────────┐ │
│  │ [icon] 추론                          │ │
│  │ ────────                              │ │
│  │ "원인-결과를 따라가지 못함"            │ │
│  └─────────────────────────────────────┘ │
│                                          │
│  [ 더 깊이 보기 → /problem ]              │
│                                          │
├─────────────────────────────────────────┤  ← section (dark)
│  SECTION 3 — 해자 삼각형 (Slide 6)        │
│                                          │
│  EYEBROW: 해자 / Moat                    │
│  H2: "4-blade Defensibility"             │
│                                          │
│         [SVG 다이어그램]                   │
│         ◢◣  XAI 검증                      │
│         ◢◣  통계 엔진                     │
│         ◢◣  MCP 네이티브                  │
│         ◢◣  도메인 데이터                 │
│                                          │
│  ┌─ XAI 검증 ──────────────────────────┐  │
│  │ "모든 결과는 추적 가능한 근거"        │  │
│  └─────────────────────────────────────┘  │
│  (4개 카드 세로 스택, 호버시 펄스)          │
│                                          │
├─────────────────────────────────────────┤  ← section (light)
│  SECTION 4 — 5단계 워크플로우 (Slide 3)    │
│                                          │
│  EYEBROW: 작동 원리                       │
│  H2: "30초 안에 검증 가능한 의사결정"      │
│                                          │
│  ① Ingest    ──→  데이터 입력             │
│  ② Detect    ──→  이상치/상관관계         │
│  ③ Simulate  ──→  What-if 시뮬레이션      │
│  ④ Reverse   ──→  목표→입력 역산          │
│  ⑤ Explain   ──→  XAI 근거 출력           │
│                                          │
│  (모바일: 세로 스텝 인디케이터, 각 단계     │
│   탭 시 1줄 설명 펼침)                     │
│                                          │
│  [ 데모 영상 보기 → /how-it-works ]        │
│                                          │
├─────────────────────────────────────────┤  ← section (tinted #F2F4F7)
│  SECTION 5 — 시장 지표 (Slide 4)          │
│                                          │
│  EYEBROW: 시장 / Market                  │
│  H2: "왜 지금인가"                        │
│                                          │
│  ┌──────────┐ ┌──────────┐               │
│  │ $81B     │ │ $50.1B   │               │
│  │ Bull TAM │ │ Base TAM │               │
│  └──────────┘ └──────────┘               │
│  ┌──────────┐ ┌──────────┐               │
│  │ $36.3B   │ │ +28.5%   │               │
│  │ Worst    │ │ CAGR     │               │
│  └──────────┘ └──────────┘               │
│  (숫자는 IntersectionObserver 카운트업)    │
│                                          │
│  [ 시장 근거 보기 → /company/market ]      │
│                                          │
├─────────────────────────────────────────┤  ← section (dark, repeat CTA)
│  SECTION 6 — Final CTA Slab               │
│                                          │
│  H2: "지금 데모 신청하세요"                │
│  LEAD: "30분 통화 + 데이터 1건 무료 분석"  │
│                                          │
│  [ Request Demo  → ]  primary             │
│  [ Contact Sales ]    secondary            │
│                                          │
├─────────────────────────────────────────┤
│  FOOTER                                  │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- **Hero**: 좌측 60% (텍스트 + CTA), 우측 40% (X 심볼 + 그라디언트 글로우 애니메이션). max_width 1240px, gutter 32px.
- **Section 2 (3가지 한계)**: 3 컬럼 그리드, `grid-template-columns: repeat(3, 1fr)`, gap 24px.
- **Section 3 (해자)**: 좌측 SVG 50% + 우측 4 카드 2x2 그리드 50%.
- **Section 4 (워크플로우)**: 5 스텝 가로 인디케이터, 각 단계 카드 250px 폭. 모바일에서는 세로 stack.
- **Section 5 (시장)**: 4 KPI 카드 1열 정렬.
- **Section 6 (Final CTA)**: 중앙 정렬 단일 컬럼, max-width 720px.

---

## 4. i18n 키 슬롯

```yaml
# config/locales/ko/landing.yml
landing:
  hero:
    eyebrow: "Post-LLM Decision Intelligence"
    headline: "LLM이 못 푸는 수치를,\n우리가 증명한다."
    lead: "통계·시뮬레이션·Reverse What-If로\nLLM 너머의 의사결정을 풉니다."
    cta_primary: "데모 신청"
    cta_secondary: "IR 자료 받기"
  problem_teaser:
    eyebrow: "문제"
    h2: "왜 LLM만으로 부족한가"
    cards:
      - { icon: alert,  title: "환각",  body: "그럴듯한 숫자가 틀린 숫자" }
      - { icon: lock,   title: "보안",  body: "기업 데이터는 외부 LLM에 못 보냄" }
      - { icon: split,  title: "추론",  body: "원인-결과를 따라가지 못함" }
    cta: "더 깊이 보기"
  moat: { eyebrow: "해자", h2: "4-blade Defensibility", ... }
  workflow: { eyebrow: "작동 원리", h2: "30초 안에 검증 가능한 의사결정", ... }
  market: { eyebrow: "시장", h2: "왜 지금인가", ... }
  final_cta: { h2: "지금 데모 신청하세요", lead: "30분 통화 + 데이터 1건 무료 분석" }
```

영문 미러는 `config/locales/en/landing.yml` (CEO 검수 후 확정).

---

## 5. 인터랙션

- **Hero CTA hover**: blue→teal 그라디언트 페이드 (300ms ease-out, `motion.fast`)
- **카운트업**: `IntersectionObserver(threshold: 0.5)` → Stimulus `countup_controller` (200ms 간격, 1.6s 총 길이)
- **해자 카드 hover**: 4 카드 중 하나 호버 시 SVG 해당 blade가 teal로 펄스
- **5단계 스텝**: 모바일에서 탭하면 설명 expand (accordion), 데스크톱은 hover로 1줄 표시
- **스크롤 큐**: Hero 하단 ▾ 아이콘 1.2s ease-in-out 무한 (prefers-reduced-motion = none)

---

## 6. LCP 예산

| 자원 | 크기 | 로딩 |
|---|---|---|
| HTML | ~12KB | render-blocking 없음 |
| Critical CSS (Hero 한정) | ~8KB | inline `<style>` |
| Hero X 심볼 SVG | ~3KB | inline |
| Pretendard subset (KS) | ~32KB | `font-display: swap`, preload |
| Inline CTA 아이콘 (Feather) | ~1KB | inline SVG sprite |
| **Above-fold 합계** | **~56KB** | 목표 100KB의 56% — 여유 ✅ |
| 카운트업 JS (Stimulus) | ~6KB | below-fold defer |
| 해자 다이어그램 SVG | ~7KB | below-fold lazy |

**LCP 후보 엘리먼트**: Hero `<h1>`. 텍스트 LCP이므로 폰트 로딩이 결정적 → preload + subset 강제.

---

## 7. 분석 이벤트

| 이벤트 | 트리거 |
|---|---|
| `page_view` | 페이지 진입 (Ahoy 자동) |
| `cta_hero_click` | Hero `Request Demo` or `IR Deck 받기` 클릭. props: `{ cta_type: "demo"|"ir", locale }` |
| `landing_section_view` | Section 2-6 50% viewport 진입. props: `{ section: "problem_teaser"|"moat"|"workflow"|"market"|"final_cta" }` |
| `final_cta_click` | Section 6 CTA. props: `{ cta_type, locale }` |

---

## 8. a11y

- Hero `<h1>` 단일, 이후 모든 섹션 `<h2>`
- 모든 CTA는 `<a>` 또는 `<button>` (div CTA 금지)
- 그라디언트 위 텍스트 대비: 흰색 텍스트 = `text_on_dark #e6e8f0` (WCAG AA 통과 검증 필요)
- 카운트업 영역에 `aria-live="polite"` + 최종값 + `aria-label="시장 규모 81B 달러"` (스크린리더는 카운트 과정 안 읽음)
- 스크롤 큐 ▾ 는 장식 → `aria-hidden="true"`
- 키보드 탭 순서: Logo → Nav 6개 → 언어토글 → Demo CTA → Hero Primary → Hero Secondary → 이하 섹션 순

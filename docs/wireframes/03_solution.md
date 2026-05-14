# W3 — `/solution` 솔루션 페이지 (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| 김 상무 | "LLM + 통계 + XAI 합쳐서 우리 데이터로 돌아간다" → /how-it-works |
| Investor | "4-blade 해자 = Defensibility 확보" → /company/investors |

**핵심 전환**: `/how-it-works`. 보조 `Request Demo`.

---

## 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier            [KO|EN] [Demo→]│
├─────────────────────────────────────────┤
│ (Light Hero)                             │
│ EYEBROW: 솔루션 / Solution               │
│ H1: "LLM + XAI = 의사결정"               │
│ LEAD: "LLM이 못 푸는 수치를               │
│        통계·시뮬레이션·인과 추론으로 푼다."│
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  STACK 다이어그램 (Slide 3)               │
│                                          │
│  ┌─ Layer 1 ──────────────────────────┐ │
│  │ LLM (Natural Language Interface)   │ │
│  │ "사용자 질문을 받는다"              │ │
│  └────────────────────────────────────┘ │
│  ┌─ Layer 2 ──────────────────────────┐ │
│  │ XimTier 엔진 (코어)                 │ │
│  │ ┌───────────┬───────────┬────────┐ │ │
│  │ │ 통계 분석  │ 시뮬레이션 │ Reverse│ │ │
│  │ │           │           │What-If │ │ │
│  │ └───────────┴───────────┴────────┘ │ │
│  └────────────────────────────────────┘ │
│  ┌─ Layer 3 ──────────────────────────┐ │
│  │ XAI 검증 레이어                     │ │
│  │ "모든 결과는 근거 그래프와 함께"     │ │
│  └────────────────────────────────────┘ │
│  ┌─ Layer 4 ──────────────────────────┐ │
│  │ 도메인 데이터 (사내, 비반출)         │ │
│  └────────────────────────────────────┘ │
│                                          │
├─────────────────────────────────────────┤  ← light section
│  해자 4 카드 (Slide 6 — 상세)             │
│                                          │
│  EYEBROW: 해자 / Moat                    │
│  H2: "왜 우리만 풀 수 있는가"             │
│                                          │
│  ┌─ Blade 1 ────────────────────────────┐│
│  │ [icon-network]                       ││
│  │ XAI 검증 (Explainable AI)            ││
│  │ "결과 → 근거 → 입력 변수 역추적"     ││
│  │ → /how-it-works#explain              ││
│  └──────────────────────────────────────┘│
│  ┌─ Blade 2 ────────────────────────────┐│
│  │ [icon-chart] 통계 엔진                ││
│  │ "Bayesian + Causal Inference + DOE"  ││
│  └──────────────────────────────────────┘│
│  ┌─ Blade 3 ────────────────────────────┐│
│  │ [icon-plug] MCP 네이티브              ││
│  │ "Anthropic MCP 서버로 즉시 연결"      ││
│  │ → /platform-api                      ││
│  └──────────────────────────────────────┘│
│  ┌─ Blade 4 ────────────────────────────┐│
│  │ [icon-shield] 도메인 데이터           ││
│  │ "기업 내부 데이터에서만 학습/추론"     ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  비교 — LLM vs XimTier (Slide 부록)       │
│                                          │
│  H2: "한눈에 — LLM과 무엇이 다른가"       │
│                                          │
│  ┌────────────┬────────────┬────────────┐│
│  │ 항목        │ LLM        │ XimTier    ││
│  ├────────────┼────────────┼────────────┤│
│  │ 환각         │ 있음        │ 없음 (수치)││
│  │ 출처         │ X          │ ✓ 근거추적 ││
│  │ 보안         │ 외부 의존   │ 사내 폐쇄  ││
│  │ 인과         │ X          │ ✓          ││
│  │ Reverse W-If │ X          │ ✓          ││
│  └────────────┴────────────┴────────────┘│
│  (모바일: 가로 스크롤 또는 토글)            │
│                                          │
├─────────────────────────────────────────┤  ← tinted section (CTA)
│  H2: "작동 원리가 궁금하다면"             │
│  [ 5단계 워크플로우 보기 → /how-it-works ]│
│  [ 데모 신청하기 → /demo ]                │
├─────────────────────────────────────────┤
│  FOOTER                                  │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- **Stack 다이어그램**: 4 레이어 세로 적층 — 데스크톱에서도 세로 유지 (관계가 위→아래 흐름). Layer 2의 내부 3 칼럼(통계/시뮬/Reverse)은 데스크톱에서 가로 3등분.
- **해자 4 카드**: 2×2 그리드 (gap 24px).
- **비교 테이블**: 3 컬럼 풀폭 `<table>`. 행마다 라이트 호버.

---

## 4. i18n 키 슬롯

```yaml
solution:
  hero: { eyebrow: "솔루션", h1: "LLM + XAI = 의사결정", lead: "..." }
  stack:
    layer1: { title: "LLM (Natural Language Interface)", note: "사용자 질문을 받는다" }
    layer2: { title: "XimTier 엔진 (코어)", sub: ["통계 분석", "시뮬레이션", "Reverse What-If"] }
    layer3: { title: "XAI 검증 레이어", note: "모든 결과는 근거 그래프와 함께" }
    layer4: { title: "도메인 데이터 (사내, 비반출)" }
  moat:
    eyebrow: "해자"
    h2: "왜 우리만 풀 수 있는가"
    blades:
      - { icon: network, title: "XAI 검증", body: "결과 → 근거 → 입력 변수 역추적", link: "/how-it-works#explain" }
      - { icon: chart,   title: "통계 엔진", body: "Bayesian + Causal Inference + DOE" }
      - { icon: plug,    title: "MCP 네이티브", body: "Anthropic MCP 서버로 즉시 연결", link: "/platform-api" }
      - { icon: shield,  title: "도메인 데이터", body: "기업 내부 데이터에서만 학습/추론" }
  compare:
    h2: "한눈에 — LLM과 무엇이 다른가"
    header: ["항목", "LLM", "XimTier"]
    rows:
      - ["환각", "있음", "없음 (수치 결과)"]
      - ["출처", "X", "✓ 근거추적"]
      - ["보안", "외부 의존", "사내 폐쇄"]
      - ["인과", "X", "✓"]
      - ["Reverse What-If", "X", "✓"]
  cta: { h2: "작동 원리가 궁금하다면", primary: "5단계 워크플로우 보기", secondary: "데모 신청하기" }
```

---

## 5. 인터랙션

- **Stack 다이어그램**: Layer 호버 시 해당 레이어 옅은 teal 보더 + 1.02 scale
- **Moat 카드 → blade 연결**: 카드 호버 시 (있다면) 페이지 상단 4-blade SVG의 해당 blade가 펄스
- **비교 테이블 행 hover**: 행 배경 #1f2937 → #2b3550 (0.15s)
- **CTA 슬랩 그라디언트**: blue→teal 135° BG 호버 시 90° 전환 (subtle)

---

## 6. LCP 예산

- LCP 후보: Hero `<h1>` 텍스트
- Stack 다이어그램은 모두 CSS Grid + border. 이미지/SVG 거의 없음 (~2KB)
- 위 above-fold ~30KB

---

## 7. 분석 이벤트

- `stack_layer_hover` (props: `{ layer: 1..4 }`)
- `moat_blade_click` (props: `{ blade: "xai"|"stats"|"mcp"|"data" }`)
- `compare_table_view` (테이블 50% viewport 진입)
- `solution_cta_click` (props: `{ cta: "how_it_works"|"demo" }`)

---

## 8. a11y

- Stack 다이어그램은 `<ol>` (1→2→3→4 순서 의미 있음). 각 `<li>`는 `aria-label`로 레이어 설명.
- Moat 카드 그리드는 `<ul role="list">` 또는 그냥 `<section>` + 카드 `<article>` 4개.
- 비교 테이블은 진짜 `<table>` + caption "LLM 대비 XimTier 기능 비교".
- 모든 SVG 아이콘은 `aria-hidden="true"` (옆 텍스트로 의미 전달).

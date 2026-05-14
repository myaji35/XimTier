# W5 — `/use-cases` 산업별 사례 페이지 (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| 김 상무 (제조 SME) | "제조 사례가 우리 상황과 같다" → `/cases/manufacturing` → `/contact` |
| 박 사무관 (공공) | "공공·스마트시티 운영 가능하구나" → `/cases/public` → `/company/investors` |
| Investor | "수직 4개에 동일 엔진이 통한다" → `/solution` |

**핵심 전환**: 카드 → 산업별 상세(`/cases/:slug`) → `Request Demo`.
**금지**: 모든 산업을 같은 톤으로 묶기. *각 산업의 고유 KPI 1개와 숫자 결과 1개*는 필수.

---

## 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Light Hero)                             │
│ EYEBROW: 산업별 사례 / Use Cases         │
│ H1: "동일 엔진, 4개 산업의 의사결정"        │
│ LEAD: "수직마다 데이터 모양이 다르다.       │
│        XimTier는 같은 5단계로 푼다."        │
│                                          │
├─────────────────────────────────────────┤
│  KPI 4 카드 (전체 요약)                    │
│  ┌─────────┬─────────┬─────────┬───────┐│
│  │ 4 산업   │ 12 PoC   │ ₩42억   │ 87%  ││
│  │ verticals│ active   │ pipeline│ XAI  ││
│  └─────────┴─────────┴─────────┴───────┘│
│                                          │
├─────────────────────────────────────────┤  ← tinted section
│  CASE 1 — 제조 (Manufacturing)            │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: settings]                      ││
│  │ EYEBROW: 제조 / Manufacturing         ││
│  │ H2: "OTD를 3.2% 끌어올린 SCM 결정"     ││
│  │ KPI: ⟶ OTD +3.2pp / 재고 -18%        ││
│  │                                       ││
│  │ 핵심 질문:                             ││
│  │ "다음 분기 자재 발주를 줄여도 안전한가?"││
│  │                                       ││
│  │ 결과:                                  ││
│  │ • Monte Carlo 10k 경로 시뮬            ││
│  │ • 외부 운임 지수 변동 반영              ││
│  │ • Reverse What-If로 3가지 위험 식별    ││
│  │                                       ││
│  │ [상세 보기 →] /cases/manufacturing    ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← light section
│  CASE 2 — 병원 (Hospital)                 │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: heart-pulse]                   ││
│  │ EYEBROW: 의료 / Hospital              ││
│  │ H2: "ER 대기시간 -23분, 인력 동일"      ││
│  │ KPI: ⟶ ER 평균대기 -23min            ││
│  │                                       ││
│  │ 핵심 질문:                             ││
│  │ "수요 패턴 안에서 인력 배치를 어떻게?"  ││
│  │                                       ││
│  │ 결과:                                  ││
│  │ • 12주 데이터 + 외부 기상/교통 신호    ││
│  │ • 시간대별 도착률 분포                  ││
│  │ • Reverse What-If로 병목 3곳 표시      ││
│  │                                       ││
│  │ [상세 보기 →] /cases/hospital         ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← tinted section
│  CASE 3 — 공공 (Public Sector)            │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: building]                      ││
│  │ EYEBROW: 공공 / Public                ││
│  │ H2: "보조금 11.7% 집행 효율"            ││
│  │ KPI: ⟶ 집행효율 +11.7pp               ││
│  │                                       ││
│  │ 핵심 질문:                             ││
│  │ "어느 지역·계층에 더 효과적인가?"        ││
│  │                                       ││
│  │ 결과:                                  ││
│  │ • 공공데이터 + 인구통계 결합            ││
│  │ • DiD 인과추론으로 효과 분리            ││
│  │ • 감사용 근거 그래프 자동 생성          ││
│  │                                       ││
│  │ [상세 보기 →] /cases/public           ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← light section
│  CASE 4 — 스마트시티 (Smart City)         │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: map]                           ││
│  │ EYEBROW: 스마트시티 / Smart City      ││
│  │ H2: "교통신호 최적화로 통행 -8%"        ││
│  │ KPI: ⟶ 평균통행시간 -8%               ││
│  │                                       ││
│  │ 핵심 질문:                             ││
│  │ "출퇴근 시간대 신호 사이클을 어떻게?"   ││
│  │                                       ││
│  │ 결과:                                  ││
│  │ • IoT 센서 + 교통량 시계열             ││
│  │ • 6개 교차로 동시 최적화                ││
│  │ • Reverse What-If로 부작용 사전 점검   ││
│  │                                       ││
│  │ [상세 보기 →] /cases/smart-city       ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← dark CTA slab
│  H2: "당신의 산업도 풀 수 있습니다"          │
│  LEAD: "수직 4개의 공통점:                  │
│         사내 데이터 + 외부 신호 + 결정."     │
│  [Request Demo →]                        │
│  [Read /solution →]                       │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- Hero: 좌 60% 카피 / 우 40% 4-vertical 미니 아이콘 (제조/병원/공공/스마트시티)
- KPI 4 카드: full-width 1-row
- CASE 카드: 2x2 그리드 (제조|병원 / 공공|스마트시티). 카드 좌 60% 카피 + 우 40% KPI 빅 넘버 + 미니 라인차트
- 카드 hover: lift + 우측 화살표 fade-in
- CTA 슬랩: full-bleed 다크 + 중앙 정렬

데스크톱 추가 요소:
- 산업 필터 chip (모든 / 제조 / 의료 / 공공 / 스마트시티) — sticky top, 진입 시 카드 스크롤
- 모바일에서는 chip 가로 스크롤 (no sticky)

---

## 4. 컨텐츠 슬롯 / i18n 키

| 슬롯 | ko 키 | en 키 | 카피 예시 (ko) |
|---|---|---|---|
| Hero eyebrow | `cases.hero.eyebrow_ko/en` | — | "산업별 사례" |
| Hero h1 | `cases.hero.h1_ko/en` | — | "동일 엔진, 4개 산업의 의사결정" |
| KPI 4 카드 | `cases.kpi.{verticals,poc,pipeline,xai}_ko/en` | — | "4 산업 / 12 PoC / ₩42억 / 87% XAI" |
| Case N title | `cases.{slug}.title_ko/en` | — | 위 H2 |
| Case N kpi | `cases.{slug}.kpi_ko/en` | — | "OTD +3.2pp / 재고 -18%" |
| Case N question | `cases.{slug}.question_ko/en` | — | 핵심 질문 |
| Case N results | `cases.{slug}.results_ko/en` (3개 배열) | — | 결과 bullet |
| Filter chip labels | `cases.filter.{all,manufacturing,hospital,public,smart_city}_ko/en` | — | "전체 / 제조 / 의료 / 공공 / 스마트시티" |

**숫자 별도 키**: 한국어 `₩42억`, 영문 `$3.2M` 자동 환산 금지(PRD §6.4). `cases.kpi.pipeline_ko = "₩42억"` / `cases.kpi.pipeline_en = "$3.2M"`.

**라우트 확장**: `/cases/:slug` 4개 slug (`manufacturing`, `hospital`, `public`, `smart-city`) — 이미 `config/routes.rb`에 reserved. 각 slug 상세 페이지는 별도 이슈로 분리.

---

## 5. 인터랙션

| 요소 | 동작 |
|---|---|
| KPI 4 카드 카운트업 | viewport 진입 시 0→target 1.4s ease-out (Stimulus `count_up_controller`) |
| Filter chip (데스크톱) | 클릭 시 해당 카드로 smooth scroll + URL hash `#manufacturing` 등 |
| Case 카드 hover | lift -2px + 화살표 X축 8px translate |
| `/cases/:slug` 진입 | Turbo morph (페이지 전환 부드럽게) |

Stimulus: `count_up_controller.js`, `case_filter_controller.js` (신규, 모바일 미작동)

---

## 6. LCP 예산

- Above-fold: Hero(라이트 그라디언트) + KPI 4 카드 (텍스트만) ≤ 80KB
- 4개 CASE 카드 아이콘은 인라인 SVG feather (총 < 4KB)
- 미니 라인차트(데스크톱 only)는 IntersectionObserver lazy SVG, 카드당 < 2KB
- 사진/일러스트 X — 산업 아이콘은 feather monoline로 통일 (anti_pattern: photo_stock 회피)

---

## 7. 분석 이벤트

| 이벤트 | 트리거 |
|---|---|
| `cases_page_view` | 페이지 로드 |
| `case_card_view` | 카드 진입 (slug payload) |
| `case_card_click` | "상세 보기" 클릭 (slug payload) |
| `case_filter_click` | filter chip 클릭 (filter payload) |
| `cta_demo_click` | CTA 슬랩 데모 클릭 |
| `lang_toggle` | KO/EN 토글 |

---

## 8. a11y

- 4개 CASE = `<article>` 마크업 (`role="article"` 명시 불필요)
- 각 카드 안 KPI 빅 넘버는 `aria-label="{metric_label} {value}"`로 스크린리더 친화
- Filter chip은 `role="tablist"` + 각 chip `role="tab" aria-selected`
- 키보드: Tab으로 4 카드 + 각 카드 내부 CTA 도달 가능
- 대비: tinted 섹션 #F2F4F7 위 본문 #475569 — WCAG AA 통과
- 모바일 가로 스크롤 chip은 키보드 사용자 대비 `<select>` fallback 옵션 (M2 단계에서 결정)

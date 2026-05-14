# W4 — `/how-it-works` 작동 원리 페이지 (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| 김 상무 (제조 SME) | "5단계로 정리되네 — 데이터만 있으면 시작 가능" → `/contact` 또는 `/demo` |
| Sarah (MCP 개발자) | "Reverse What-If는 인과추론 + DP-SGD 노이즈로 보호되는구나" → `/platform-api` |
| Investor | "Explainable + Reverse What-If = 진짜 해자" → `/company/investors` |

**핵심 전환**: `Request Demo`. 보조: `/platform-api` (개발자).
**금지**: 추상 다이어그램만 보여주고 끝내기. 5단계 각각에 *수치 예시*를 박는다.

---

## 2. 모바일 와이어 (360px 정본)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Dark Hero — section_dark #0B132D)       │
│ EYEBROW: 작동 원리 / How it works        │
│ H1: "5단계로 의사결정을 풀어낸다"          │
│ LEAD: "질문→데이터→시뮬레이션→설명→실행. │
│        모든 결과는 근거 그래프와 함께."    │
│ [그라디언트 stroke divider]              │
│                                          │
├─────────────────────────────────────────┤  ← light section
│  STEP 1 — 질문                            │
│  EYEBROW: STEP 1 / Question              │
│  H2: "자연어로 묻는다"                    │
│  BODY: "'재고를 30% 줄이면 OTD는?'         │
│        같은 비전문가 문장을 받는다."        │
│  EX: "예시 입력 → 'Q1 재고 30%↓'"          │
│  ICON: speech-bubble (feather)            │
│                                          │
├─────────────────────────────────────────┤  ← tinted section
│  STEP 2 — 데이터 결합                     │
│  H2: "사내 데이터 + 외부 신호 결합"         │
│  BODY: "ERP/MES/공급망 → entity graph     │
│        + 외부 시장 신호(공개 데이터)."     │
│  EX: "node 47k / edge 312k / latency 12s"│
│  ICON: graph (feather)                    │
│                                          │
├─────────────────────────────────────────┤  ← light section
│  STEP 3 — 시뮬레이션 (Monte Carlo)        │
│  H2: "10,000회 경로를 돌린다"              │
│  BODY: "Bull/Base/Worst 3시나리오 분포 +   │
│        민감도 변수 자동 추출."             │
│  EX: "P(OTD↑3%)=72% / P(Cash↓10%)=18%"   │
│  ICON: bar-chart (feather)                │
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  STEP 4 — XAI 설명 (Reverse What-If)      │
│  H2: "결과 → 근거 → 변수 역추적"           │
│  BODY: "어떤 입력 변수가 결과를 흔드는지    │
│        SHAP+do-calculus로 인과 분리."      │
│  EX: "원인 가중치 표 + 시각화"              │
│  ICON: search (feather)                   │
│  CTA mini: [Reverse What-If 보기 →]      │
│                                          │
├─────────────────────────────────────────┤  ← light section
│  STEP 5 — 실행 & 모니터링                  │
│  H2: "결정을 실행 가능한 형태로 출력"        │
│  BODY: "ERP에 패치 / MCP로 다른 시스템에    │
│        명령 / 운영 KPI 추적."              │
│  EX: "API/Webhook/MCP/Slack 출력 4종"     │
│  ICON: zap (feather)                      │
│                                          │
├─────────────────────────────────────────┤
│  REVERSE WHAT-IF 상세 카드 (deep dive)    │
│  EYEBROW: 핵심 차별화                      │
│  H2: "Reverse What-If — 왜 이 결과인가?"   │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ "OTD가 3% 오를 거라고 예측한 이유"     ││
│  │  ▼                                    ││
│  │  ① 공급망 리드타임 -2일 (가중치 0.41) ││
│  │  ② 재고 회전율 +0.3 (가중치 0.28)    ││
│  │  ③ 외부 운임 지수 -7% (가중치 0.18)  ││
│  │  → 합산 87% 설명 가능                 ││
│  │                                       ││
│  │  [근거 그래프 보기 →]                  ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  데이터 거버넌스 슬랩 (작은 신뢰 빌딩)      │
│  H3: "데이터는 회사 안에 머문다"            │
│  • On-premise / VPC 옵션                  │
│  • DP-SGD 노이즈로 프라이버시 보장          │
│  • 감사 로그 & RBAC                        │
│                                          │
├─────────────────────────────────────────┤  ← CTA 슬랩
│  H2: "당신 데이터로 5단계를 돌려보세요"     │
│  [Request Demo →] (primary CTA)          │
│  [Read Case Studies →] (link)            │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- Hero: 좌 70% 카피 / 우 30% step indicator (1→5 가로 진행 바, 현재 0/5)
- STEP 1~5: 2-col `[설명 65% | 예시 카드 35%]`. tinted/light 교차로 리듬
- STEP 4(Reverse What-If) 상세 카드: full-bleed 다크 섹션 + 좌 카피 / 우 그래프 SVG (Monte Carlo 분포 mini-plot)
- 거버넌스 슬랩: 3-col (`On-prem`, `DP-SGD`, `Audit`)
- CTA 슬랩: 중앙 정렬 1열

데스크톱 sticky right rail (optional, 1024px+): 5단계 step indicator를 스크롤 진행에 따라 강조

---

## 4. 컨텐츠 슬롯 / i18n 키

| 슬롯 | ko 키 | en 키 | 카피 예시 (ko) |
|---|---|---|---|
| Hero eyebrow | `how.hero.eyebrow_ko` | `how.hero.eyebrow_en` | "작동 원리" |
| Hero h1 | `how.hero.h1_ko` | `how.hero.h1_en` | "5단계로 의사결정을 풀어낸다" |
| Hero lead | `how.hero.lead_ko` | `how.hero.lead_en` | "질문 → 데이터 → 시뮬레이션 → 설명 → 실행" |
| Step N title | `how.step{1..5}.title_ko/en` | — | "질문" / "데이터 결합" / "시뮬레이션" / "XAI 설명" / "실행" |
| Step N body | `how.step{1..5}.body_ko/en` | — | 위 본문 |
| Step N example | `how.step{1..5}.example_ko/en` | — | 위 EX 라인 |
| Reverse What-If title | `how.rwif.h2_ko/en` | — | "Reverse What-If — 왜 이 결과인가?" |
| Reverse What-If items | `how.rwif.items_ko/en` (3개 배열) | — | 위 ①②③ |
| Governance items | `how.governance.items_ko/en` (3개) | — | "On-prem / DP-SGD / RBAC" |
| CTA primary | `how.cta.primary_ko/en` | — | "데모 신청" / "Request Demo" |

**한/영 길이 차 대응**: STEP 카드 본문은 영문 기준 최대 130자, 한글은 80자에 맞춰 디자인. Hero H1은 2줄 변환 안전 영역(영문 최대 56자) 안.

---

## 5. 인터랙션

| 요소 | 동작 |
|---|---|
| STEP indicator | viewport 진입 시 currentStep 증가 (IntersectionObserver, Stimulus `step-progress` controller) |
| Reverse What-If 카드 | 3개 항목이 차례로 fade-in (모바일은 동시, 데스크톱은 stagger 80ms) |
| Monte Carlo mini-plot | 데스크톱 only — 진입 시 1.2s SVG path stroke 애니메이션 (단발성) |
| CTA hover | `hover_effect: lift` (translateY -2px + shadow lg) |
| 언어 토글 | `/how-it-works` ↔ `/en/how-it-works` 동일 hash 유지 |

Stimulus 컨트롤러: `step_progress_controller.js`, `count_up_controller.js` (재사용)

---

## 6. LCP 예산

- Above-fold: Hero(다크 그라디언트 CSS) + STEP indicator SVG(인라인, <3KB) ≤ 90KB
- 폰트: Pretendard regular/semibold만 (woff2 subset)
- Monte Carlo plot SVG: below-fold, IntersectionObserver로 stroke 애니메이션
- 거버넌스 슬랩 아이콘: 인라인 SVG feather (lazy 불필요, 전체 < 6KB)
- 모든 페이지에서 동일하게 hreflang link 자동 출력 (FR-10)

---

## 7. 분석 이벤트

| 이벤트 | 트리거 |
|---|---|
| `how_step_view` | STEP 1..5 진입 시 (step number payload) |
| `how_rwif_view` | Reverse What-If 카드 진입 |
| `how_rwif_graph_click` | "근거 그래프 보기" 클릭 |
| `cta_demo_click` | 데모 CTA 클릭 (page=`how`) |
| `cta_cases_click` | 사례 링크 클릭 |
| `lang_toggle` | KO/EN 토글 (페이지=`how`) |

Plausible(FR-11) custom events. PII 없음.

---

## 8. a11y

- STEP 1..5 = `<ol>` semantic, 각 step `<li>` 안에 `<h2>`
- Step indicator는 `aria-current="step"`을 현재 step에 부여
- Reverse What-If 카드의 3개 인과 항목은 `<dl>` (term=원인, dd=가중치+설명)
- 키보드 포커스: Tab으로 모든 mini CTA 도달 가능
- 대비: 다크 섹션 텍스트 #E2E8F0 / 라이트 섹션 #0B132D — WCAG AA 통과
- Stimulus 애니메이션은 `prefers-reduced-motion: reduce` 환경에서 즉시 표시

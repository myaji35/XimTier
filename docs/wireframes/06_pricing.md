# W6 — `/pricing` 가격 페이지 (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| 김 상무 (제조 SME) | "PoC → Pilot → Production 단계 알겠음" → `/contact` |
| Investor | "4단계 BM = ARR 예측 가능 + Land&Expand" → `/company/investors` |
| Sarah (개발자) | "Developer Tier로 시작 가능" → `/platform-api` |

**핵심 전환**: `Contact Sales` (Enterprise) / `Request Demo` (Pilot+) / `Sign up` (Developer).
**금지**: 가격을 숨기는 "Contact us" 일색. *3개 티어는 가격 범위 명시*, Enterprise만 협의.

---

## 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Light Hero)                             │
│ EYEBROW: 가격 / Pricing                  │
│ H1: "PoC부터 시작, 결과로 확장"            │
│ LEAD: "초기 4주 검증 → 6개월 파일럿 →     │
│        프로덕션 → 산업별 확장."           │
│                                          │
├─────────────────────────────────────────┤
│  통화 토글: [KRW | USD]                   │
│  (i18n locale에 따라 기본값:               │
│   ko=KRW, en=USD)                        │
│                                          │
├─────────────────────────────────────────┤  ← tinted section
│  TIER 1 — DEVELOPER                       │
│  ┌──────────────────────────────────────┐│
│  │ EYEBROW: 개발자                       ││
│  │ H2: "Developer"                       ││
│  │ PRICE: 무료 / Free                    ││
│  │ DESC: "MCP/Plugin SDK 액세스.         ││
│  │        샌드박스 데이터셋 포함."         ││
│  │                                       ││
│  │ 포함:                                  ││
│  │ ✓ MCP Server SDK (TS/Python)          ││
│  │ ✓ Sandbox dataset (10k entities)      ││
│  │ ✓ Reverse What-If demo API            ││
│  │ ✓ Community Slack                     ││
│  │                                       ││
│  │ 제외:                                  ││
│  │ ✗ 자사 데이터 연동                     ││
│  │ ✗ SLA                                 ││
│  │                                       ││
│  │ [Sign up →] (link, secondary)         ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← light section
│  TIER 2 — PoC                             │
│  ┌──────────────────────────────────────┐│
│  │ EYEBROW: 초기 검증                     ││
│  │ H2: "PoC (4주)"                       ││
│  │ PRICE: ₩30M~ / from $22K              ││
│  │ DESC: "단일 시나리오, 사내 데이터,      ││
│  │        4주 안에 결과 보장."            ││
│  │                                       ││
│  │ 포함:                                  ││
│  │ ✓ 1 시나리오 + 도메인 데이터 결합      ││
│  │ ✓ Monte Carlo 10k 경로                ││
│  │ ✓ Reverse What-If 보고서              ││
│  │ ✓ 1 워크숍 + 결과 발표                ││
│  │                                       ││
│  │ [Request PoC →] (primary CTA)        ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← tinted, ★HIGHLIGHTED
│  TIER 3 — PILOT                           │
│  ┌──────────────────────────────────────┐│
│  │ ⭐ 가장 인기 / Most Popular           ││
│  │ EYEBROW: 6개월 파일럿                  ││
│  │ H2: "Pilot"                           ││
│  │ PRICE: ₩200M~ / from $150K           ││
│  │ DESC: "3 시나리오, 운영 대시보드,       ││
│  │        VPC 배포, 매주 인사이트."        ││
│  │                                       ││
│  │ 포함:                                  ││
│  │ ✓ 3 시나리오 + 외부 신호 결합          ││
│  │ ✓ 운영 콘솔 + KPI 대시보드             ││
│  │ ✓ VPC/On-prem 배포                    ││
│  │ ✓ 주 1회 인사이트 보고                 ││
│  │ ✓ 99.5% SLA                           ││
│  │ ✓ Slack 공유 채널                      ││
│  │                                       ││
│  │ [Request Pilot →] (primary CTA, big) ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  TIER 4 — ENTERPRISE                      │
│  ┌──────────────────────────────────────┐│
│  │ EYEBROW: 프로덕션                      ││
│  │ H2: "Enterprise"                      ││
│  │ PRICE: 협의 / Contact                 ││
│  │ DESC: "수직 다중 시나리오,              ││
│  │        SOC2, 다국가, 24/7 지원."        ││
│  │                                       ││
│  │ 포함:                                  ││
│  │ ✓ 무제한 시나리오                      ││
│  │ ✓ Multi-region / multi-tenant         ││
│  │ ✓ SOC2 Type 2 / ISO 27001            ││
│  │ ✓ 24/7 지원 + 99.95% SLA              ││
│  │ ✓ Custom 산업 모델 학습                ││
│  │ ✓ White-glove 온보딩                  ││
│  │                                       ││
│  │ [Contact Sales →] (primary CTA)      ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← light section
│  비교표 (Feature Matrix)                   │
│  H3: "한눈에 보기 / At a glance"           │
│                                          │
│  ┌───────────────┬─────┬───┬───┬───┐    │
│  │ 기능          │ Dev │PoC│Plt│Ent│    │
│  ├───────────────┼─────┼───┼───┼───┤    │
│  │ 시나리오 수    │  -  │ 1 │ 3 │ ∞ │    │
│  │ 자사 데이터    │  -  │ ✓ │ ✓ │ ✓ │    │
│  │ Reverse What-If│  체험│ ✓ │ ✓ │ ✓ │    │
│  │ VPC/On-prem   │  -  │ - │ ✓ │ ✓ │    │
│  │ SLA           │  -  │ - │99.5│99.95│  │
│  │ Custom 모델   │  -  │ - │ - │ ✓ │    │
│  │ 24/7 지원     │  -  │ - │ - │ ✓ │    │
│  │ MCP SDK       │  ✓  │ ✓ │ ✓ │ ✓ │    │
│  └───────────────┴─────┴───┴───┴───┘    │
│  (모바일: 가로 스크롤)                     │
│                                          │
├─────────────────────────────────────────┤
│  FAQ (5개)                                │
│  ▸ 데이터는 어디에 저장되나요?              │
│  ▸ PoC에서 Pilot으로 전환 시 비용은?       │
│  ▸ 환불 정책은?                            │
│  ▸ SLA 보장 범위는?                        │
│  ▸ 자체 LLM/모델 연동 가능한가요?           │
│  (각 항목 ▸ 클릭 → 답변 fold-out)          │
│                                          │
├─────────────────────────────────────────┤  ← CTA 슬랩
│  H2: "어디서 시작할지 모르겠다면"            │
│  [Schedule a call →] (primary)            │
│  [Read /how-it-works →] (link)            │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- Hero: 좌 60% 카피 / 우 40% 가격 미니 그래프 (₩→USD 환율 그래픽)
- 4 티어 카드: 1x4 가로 그리드, **Pilot 카드 강조** (배경 그라디언트 + ⭐ 배지 + scale 1.04)
- 비교표: full-width 7열 (`기능 / Dev / PoC / Pilot / Ent`), 데스크톱은 sticky header
- FAQ: 2-col accordion
- 통화 토글: 우상단 sticky chip (스크롤 시 sticky)

데스크톱 추가 마이크로 인터랙션:
- 티어 카드 hover: lift -4px + 그라디언트 stroke
- ⭐ Pilot 카드는 hover시 미세 pulse (1.04 → 1.06 → 1.04, 600ms)

---

## 4. 컨텐츠 슬롯 / i18n 키

| 슬롯 | 키 (ko/en) | 카피 예시 (ko) |
|---|---|---|
| Hero h1 | `pricing.hero.h1` | "PoC부터 시작, 결과로 확장" |
| Hero lead | `pricing.hero.lead` | "초기 4주 검증 → 6개월 파일럿 → 프로덕션" |
| Currency toggle | `pricing.currency.{krw,usd}` | "KRW / USD" |
| Tier N name | `pricing.tier.{developer,poc,pilot,enterprise}.name` | "Developer / PoC (4주) / Pilot / Enterprise" |
| Tier N price | `pricing.tier.*.price_ko / .price_en` | "무료 / 30M~ / 200M~ / 협의" vs "Free / from $22K / from $150K / Contact" |
| Tier N features | `pricing.tier.*.features` (배열) | 위 ✓ 목록 |
| Tier N excluded | `pricing.tier.*.excluded` (배열) | 위 ✗ 목록 |
| Tier N CTA | `pricing.tier.*.cta_label` | "Sign up / Request PoC / Request Pilot / Contact Sales" |
| Matrix headers | `pricing.matrix.headers` (배열) | "기능 / Dev / PoC / Pilot / Ent" |
| Matrix rows | `pricing.matrix.rows` (8개 배열) | 위 비교표 |
| FAQ items | `pricing.faq.{1..5}.{q,a}` | 위 FAQ |
| CTA slab | `pricing.cta.{h2,primary,secondary}` | "어디서 시작할지..." |

**가격 환산 규칙 (PRD §6.4 준수)**:
- 자동 환율 변환 **금지**.
- ko 사용자: 기본 KRW. 토글 시 en 키의 USD 값 그대로 표시.
- en 사용자: 기본 USD. 토글 시 ko 키의 KRW 값 표시.
- 환율 변경 시 i18n YAML 수동 업데이트 (재무팀 통보).

---

## 5. 인터랙션

| 요소 | 동작 |
|---|---|
| 통화 토글 | KRW ↔ USD 즉시 가격 표기 변경 (Stimulus `currency_toggle_controller`), localStorage 보존 |
| 티어 카드 hover | lift / Pilot은 추가 pulse |
| FAQ ▸ 클릭 | accordion fold-out (CSS `details/summary` native — JS 불필요) |
| 비교표 모바일 | 가로 스크롤 + shadow indicator (스크롤 가능 hint) |
| CTA 클릭 | Tier별로 다른 destination: PoC/Pilot → `/contact?tier={slug}`, Enterprise → `/contact?tier=enterprise`, Dev → `/users/sign_up` (M3 단계) |

---

## 6. LCP 예산

- Above-fold: Hero + 통화 토글 ≤ 80KB
- 4 티어 카드 아이콘 없음 (텍스트만) — 자연스럽게 LCP 친화
- 비교표: 텍스트, 약 4KB
- FAQ: `<details>` native 사용으로 JS 0
- 통화 토글 JS: 6KB 미만 (Stimulus 1 controller)

---

## 7. 분석 이벤트

| 이벤트 | 트리거 |
|---|---|
| `pricing_page_view` | 페이지 로드 |
| `currency_toggle` | KRW/USD 변경 (currency payload) |
| `tier_view` | 티어 카드 진입 (tier payload) |
| `tier_cta_click` | 티어 CTA 클릭 (tier, target_route payload) |
| `matrix_scroll` | 모바일 비교표 가로 스크롤 |
| `faq_open` | FAQ 항목 펼침 (faq_id payload) |
| `cta_demo_click` | 하단 CTA 슬랩 |

→ Investor가 "Pilot tier_view → tier_cta_click → /contact" 이탈률을 Plausible에서 추적.

---

## 8. a11y

- 4 티어 카드 = `<article>` + `<h2>` + `<ul>` (포함) / `<ul>` (제외)
- ⭐ "가장 인기" 배지는 `aria-label="추천 티어"` 추가
- 가격은 `<data value="30000000">₩30M~</data>` semantic
- 비교표는 `<table>` + `<th scope="col"/"row">` 완전 semantic
- FAQ `<details>` native — 스크린리더 호환 (별도 ARIA 불필요)
- 통화 토글은 `role="switch" aria-checked`
- 키보드: Tab으로 통화 토글 → 4 티어 CTA → 비교표 → FAQ 순
- 대비: Pilot 강조 카드 그라디언트 위 본문은 #FFFFFF로 WCAG AA 통과 보장

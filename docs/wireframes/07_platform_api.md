# W7 — `/platform-api` 개발자 페이지 (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| Sarah (MCP 개발자) | "MCP Server SDK + Plugin 인터페이스 명확. 30분 안에 'Hello, XimTier'" → 코드 복사 → `/users/sign_up` |
| 김 상무 (제조 SME) | "기술팀이 자체 통합 가능하구나" → `/contact?topic=integration` |
| Investor | "Developer-led growth + Platform 해자" → `/company/investors` |

**핵심 전환**: 코드 복사 (Hello world) → `Sign up` (Developer Tier 무료) → MCP Server 등록.
**금지**: 마케팅 어조의 long-copy. 개발자 페이지는 *코드 우선*, 문장 보조.

---

## 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Dark Hero — 그라디언트 + code aesthetic)│
│ EYEBROW: Platform / API                  │
│ H1: "Build agents on XimTier"            │
│ LEAD: "MCP Server SDK + Plugin runtime.  │
│        Reverse What-If as a service."    │
│                                          │
│ [Sign up free →]  [View on GitHub →]    │
│                                          │
├─────────────────────────────────────────┤
│  코드 블록 1 — "Hello, XimTier"           │
│  [TS | Python] (tab)                     │
│  ```ts                                   │
│  import { XimTier } from "@ximtier/sdk"; │
│                                          │
│  const x = new XimTier({                 │
│    apiKey: process.env.XIMTIER_KEY,      │
│  });                                     │
│                                          │
│  const result = await x.askDecision({    │
│    scenario: "재고 30% 축소",             │
│    horizonDays: 90,                       │
│  });                                      │
│  console.log(result.reverseWhatIf);      │
│  ```                                     │
│  [📋 Copy] [▶ Run in sandbox]            │
│                                          │
├─────────────────────────────────────────┤  ← tinted
│  3개 핵심 컨셉 (3 cards)                  │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: server]                        ││
│  │ MCP Server                            ││
│  │ "타사 LLM(Claude, GPT 등)에서          ││
│  │  XimTier를 도구로 호출."               ││
│  │ → /platform-api#mcp                  ││
│  └──────────────────────────────────────┘│
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: package]                       ││
│  │ Plugin SDK                            ││
│  │ "산업별 도메인 어댑터를                ││
│  │  Plugin으로 작성·배포."                ││
│  │ → /platform-api#plugins              ││
│  └──────────────────────────────────────┘│
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [icon: zap]                           ││
│  │ REST + Webhook                        ││
│  │ "기존 시스템에서 HTTP/Webhook으로      ││
│  │  Reverse What-If를 호출."              ││
│  │ → /platform-api#rest                 ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← dark
│  #mcp 섹션 — MCP Server 상세              │
│  H2: "MCP Server"                        │
│  LEAD: "Anthropic MCP 1.0+ 호환.          │
│        4개 도구(askDecision, simulate,    │
│        reverseWhatIf, explainGraph)."     │
│                                          │
│  코드 블록 2:                             │
│  ```json                                 │
│  // claude_desktop_config.json           │
│  {                                       │
│    "mcpServers": {                       │
│      "ximtier": {                        │
│        "command": "npx",                 │
│        "args": ["@ximtier/mcp-server"],  │
│        "env": {                          │
│          "XIMTIER_KEY": "xim_..."        │
│        }                                  │
│      }                                    │
│    }                                      │
│  }                                       │
│  ```                                     │
│  [📋 Copy]                                │
│                                          │
│  도구 목록 (4):                           │
│  • `askDecision(scenario)` → 결과+근거    │
│  • `simulate(params, n=10000)` → 분포     │
│  • `reverseWhatIf(outcome)` → 원인       │
│  • `explainGraph(decisionId)` → 그래프   │
│                                          │
├─────────────────────────────────────────┤  ← light
│  #plugins 섹션 — Plugin SDK 상세          │
│  H2: "Plugin SDK"                        │
│  LEAD: "산업별 데이터 어댑터를              │
│        Plugin으로 등록 → 매월 사용량 정산."│
│                                          │
│  코드 블록 3:                             │
│  ```ts                                   │
│  import { definePlugin } from "@ximtier/  │
│    plugin-sdk";                          │
│                                          │
│  export default definePlugin({           │
│    slug: "manufacturing-scm",            │
│    domain: "manufacturing",              │
│    schemas: { ... },                     │
│    async fetch(entityId) { ... }         │
│  });                                     │
│  ```                                     │
│                                          │
│  Plugin 마켓플레이스 미리보기:             │
│  ┌────────┬────────┬────────┐           │
│  │ SCM    │ ER     │ City   │           │
│  │ 제조   │ 의료   │ 스마트 │           │
│  │ 4 인스톨│ 2 인스톨│ 1 인스톨│           │
│  └────────┴────────┴────────┘           │
│  [Browse Plugin Marketplace →] (M4 단계) │
│                                          │
├─────────────────────────────────────────┤  ← tinted
│  #rest 섹션 — REST + Webhook              │
│  H2: "REST API"                          │
│                                          │
│  엔드포인트 표 (간이):                     │
│  ┌────────┬────────────────────────────┐ │
│  │ POST   │ /v1/decisions               │ │
│  │ GET    │ /v1/decisions/:id           │ │
│  │ POST   │ /v1/reverse-what-if         │ │
│  │ POST   │ /v1/webhooks/subscribe      │ │
│  └────────┴────────────────────────────┘ │
│                                          │
│  레이트 리밋: 60 req/min (Dev) /          │
│             600 req/min (Pilot+)          │
│                                          │
├─────────────────────────────────────────┤  ← dark CTA
│  H2: "30분 만에 첫 결정"                   │
│  LEAD: "Developer Tier는 무료.            │
│        Sandbox 데이터셋 포함."            │
│  [Sign up free →] [View Docs →]          │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- Hero: 좌 55% 카피 / 우 45% **터미널 모티프** ASCII art (JetBrains Mono, 그라디언트 cursor blink)
- 코드 블록 1 (Hello world): 좌 50% 코드 / 우 50% 결과 (sandbox preview, M4 단계 추가)
- 3개 핵심 컨셉: 1x3 카드, hover 시 좌측 anchor 스크롤
- #mcp/#plugins/#rest 섹션: 좌 50% 카피 / 우 50% 코드 블록 — sticky right rail (코드가 스크롤 따라 sticky)
- 데스크톱 sticky 좌측 nav: `Quickstart / MCP / Plugins / REST / Webhooks / Auth / Rate Limits` 7개 항목 anchor 점프

코드 블록 디자인:
- 배경: `#0B132D` (deep_navy)
- 글자: `#E2E8F0` 베이스 + `#00C8C8` (teal_mint) keyword + `#FBBF24` string
- 폰트: JetBrains Mono 14px / 1.6 line-height
- 헤더 바: `[TS | Python]` tab + 우측 `📋 Copy / ▶ Run` 버튼

---

## 4. 컨텐츠 슬롯 / i18n 키

| 슬롯 | 키 | 카피 예시 (ko) |
|---|---|---|
| Hero h1 | `platform.hero.h1` | "Build agents on XimTier" (영문 그대로 유지, 개발자 톤) |
| Hero lead | `platform.hero.lead` | ko: "MCP Server SDK + Plugin runtime. Reverse What-If as a service." / en 동일 골조 |
| 3 컨셉 카드 | `platform.concept.{mcp,plugin,rest}.{title,desc}` | "MCP Server / Plugin SDK / REST + Webhook" |
| #mcp h2 | `platform.mcp.h2` | "MCP Server" |
| #mcp 도구 4개 | `platform.mcp.tools` (배열) | `askDecision/simulate/reverseWhatIf/explainGraph` |
| #plugins h2 | `platform.plugin.h2` | "Plugin SDK" |
| #plugins marketplace 카드 | `platform.plugin.marketplace.{slug}.{name,domain,installs}` | "SCM / 제조 / 4 인스톨" |
| #rest 엔드포인트 표 | `platform.rest.endpoints` (배열) | POST /v1/decisions 등 |
| Rate limits | `platform.rest.rate_limits.{dev,pilot}` | "60 / 600 req/min" |
| CTA | `platform.cta.{primary,secondary}` | "Sign up free / View Docs" |

**언어 처리 원칙**:
- 코드 블록 안 변수명·함수명은 **언어 불변** (영문 식별자만).
- 코드 주석은 i18n 처리: ko 페이지는 한글 주석, en 페이지는 영문 주석. SDK 사용 시 사용자가 작성하는 주석은 자유.
- 콘솔 출력 예시(`console.log(...)`)는 영문 고정 (실제 SDK 출력과 일치).

---

## 5. 인터랙션

| 요소 | 동작 |
|---|---|
| 코드 블록 tab (TS/Python) | 클릭 시 코드 전환 (Stimulus `code_tab_controller`), URL hash에 lang 보존 |
| 📋 Copy | clipboard API + 토스트 "Copied!" (1.2s) |
| ▶ Run in sandbox | M4 단계 — `/sandbox?example={id}` 새창 (현재는 disabled) |
| 좌측 sticky nav (데스크톱) | 스크롤 진행 시 currentSection 강조 (`scroll-spy`) |
| anchor 점프 | smooth scroll + URL hash 갱신 |
| 코드 블록 hover | 우상단 `Copy/Run` 버튼 opacity 0 → 1 |
| Hero "View on GitHub" | `https://github.com/ximtier/sdk` 새창 (rel="noopener") |

Stimulus 컨트롤러: `code_tab_controller.js`, `clipboard_controller.js`, `scroll_spy_controller.js`

---

## 6. LCP 예산

- Above-fold: Hero(다크 그라디언트) + 첫 코드 블록 일부 ≤ 95KB
- JetBrains Mono woff2 subset (ASCII + 일부 emoji) ~ 22KB
- 코드 syntax highlight: **Server-side rendering** (Rouge gem) — 클라이언트 highlighter X
- 4 가지 코드 블록 중 첫 1개만 초기 로드, 나머지 3개는 anchor 진입 시 fetch (Turbo frame)
- 터미널 ASCII 모티프(데스크톱 only)는 인라인 SVG/CSS, < 4KB

---

## 7. 분석 이벤트

| 이벤트 | 트리거 |
|---|---|
| `platform_page_view` | 페이지 로드 |
| `code_tab_switch` | TS ↔ Python 전환 (block_id, lang) |
| `code_copy` | 📋 Copy 클릭 (block_id) |
| `code_run_click` | ▶ Run 클릭 (M4 활성 시) |
| `concept_card_click` | 3 컨셉 카드 클릭 |
| `endpoint_table_view` | REST 엔드포인트 표 진입 |
| `github_link_click` | View on GitHub |
| `cta_signup_click` | Sign up free CTA |
| `cta_docs_click` | View Docs |

→ Sarah 캐릭터 저니의 핵심 KPI: `code_copy` 발생 시 *전환 의도 강함* 신호로 마케팅팀에 weekly 리포트.

---

## 8. a11y

- 코드 블록은 `<pre><code class="language-ts">` semantic
- Copy 버튼은 `aria-label="코드 복사"` / 클릭 후 `aria-live="polite"` 토스트
- 4 도구 목록은 `<dl>` (term=함수 시그니처, dd=설명)
- 좌측 sticky nav은 `<nav aria-label="Page sections">` + `<ol>` + `aria-current="location"` 진행 위치
- 코드 블록 색상은 WCAG AA 통과 (teal_mint #00C8C8 on deep_navy #0B132D = 4.7:1)
- 키보드: Tab으로 모든 Copy/Run/anchor 도달 가능. anchor는 Enter로 점프
- 사용자가 `prefers-reduced-motion: reduce`면 sticky nav scroll-spy 즉시 갱신, smooth scroll → instant

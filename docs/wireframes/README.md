# XimTier 와이어프레임 — 한/영 IA + 8 페이지

> 이슈: **XIM-11** (DESIGN, in_progress, high)
> 작성: 2026-05-14 / UXDesigner agent
> 베이스: `prd.md` §3 (IA) + `xaisimtier/brand-dna.json` (디자인 토큰) + `_workspace/market-page-spec.md`
> 산출: markdown wireframe (Figma 대체). 모바일 우선, **LCP < 2.5s**, Above-fold < 100KB 룰 강제.

---

## 0. 결정 사항 (Decisions taken without polling)

| 항목 | 결정 | 근거 |
|---|---|---|
| Wireframe 포맷 | **Markdown + ASCII 와이어** (Figma 미사용) | PRD §3에서 *"Figma 또는 markdown wireframe"* 명시. 레포 네이티브 검토 가능하고 PR 리뷰에 그대로 올라감 |
| 페이지 수 | **8 페이지 (PRD 우선 8개)** + `company/team`, `company/vision`, `company/investors`는 `/company` 하위 IA 분기로 같은 와이어프레임 안에 명시 | 이슈 본문이 8개로 못 박음. `/company/*`는 sub-IA로 처리해 8개에 카운트되지 않도록 함 |
| 한/영 처리 | **단일 와이어프레임 + 카피 슬롯(ko/en) 표기** | PRD §3 *"한/영 동일 구조"*. 동일 골조 + i18n 키 슬롯만 표시 |
| 모바일 우선 | 모든 와이어프레임은 **360px 모바일을 정본**으로 그리고, 데스크톱(≥980px)은 컬럼 확장 규칙만 명시 | `brand-dna.breakpoints` = mobile_max 979 / desktop_min 980 |
| Above-fold 예산 | **Hero 100KB 미만 (이미지 X, SVG/CSS 그라디언트만)** | PRD §8.3 + `brand-dna.page_priorities.above_fold_kb: 100` |

---

## 1. 정보 구조 (IA) — 한/영 미러

```
xaisimtier.com
├── / (Accept-Language 자동 분기 → /ko 또는 /en)
│
├── /ko (한국어 기본)
│  ├── /                       ← (W1) 랜딩
│  ├── /problem                ← (W2) 문제
│  ├── /solution               ← (W3) 솔루션
│  ├── /how-it-works           ← (W4) 작동 원리 (5단계 워크플로우 + Reverse What-If)
│  ├── /use-cases              ← (W5) 산업별 사례 (제조/병원/공공/스마트시티)
│  ├── /pricing                ← (W6) 4단계 BM
│  ├── /platform-api           ← (W7) MCP/Plugin 개발자
│  ├── /company                ← (W8) 회사 (하위: team / vision / investors)
│  │   ├── /team
│  │   ├── /vision
│  │   └── /investors          ← IR PDF 다운로드 (이메일 게이트)
│  ├── /contact                ← (보조) 문의 — 8개 외 (PRD 명시 페이지)
│  ├── /demo                   ← (보조) 데모 신청 — 8개 외
│  ├── /docs, /privacy, /terms ← 부속
│  ├── /users/sign_in          ← Devise
│  └── /dashboard              ← 인증 사용자 영역
│
└── /en (English mirror — 동일 구조, 카피만 교체)
```

### 1.1 글로벌 네비게이션 (모든 페이지 공통)

```
┌────────────────────────────────────────────────────────────────────┐
│  [X] XimTier        Problem  Solution  How  Cases  Pricing  …  [KO|EN]  [Request Demo→] │
└────────────────────────────────────────────────────────────────────┘
```

- 모바일: 햄버거 메뉴 + 우측 sticky CTA (`Request Demo`)
- 데스크톱: 좌 로고 + 중앙 메뉴 + 우 언어토글 + 강조 CTA
- 언어토글 = `[KO | EN]` 세그먼티드 컨트롤. 클릭 시 동일 경로의 mirror URL로 이동 (`/ko/pricing` ↔ `/en/pricing`)
- `<link rel="alternate" hreflang>` 양방향 자동 출력

### 1.2 글로벌 풋터

```
┌───────────────────────────────────────────────────────────────────┐
│  Product     Company      Resources    Legal       [X] XimTier    │
│  /problem    /company     /docs        /privacy    "Decision      │
│  /solution   /team        /platform-api /terms      Intelligence, │
│  /how-it...  /vision      /contact                  Proven by     │
│  /use-cases  /investors                             Numbers."     │
│  /pricing    /demo                                                │
│                                                                   │
│  © 2026 XimTier · Gagahoho Inc. · contact@xaisimtier.ai          │
└───────────────────────────────────────────────────────────────────┘
```

---

## 2. 디자인 토큰 (와이어프레임 적용 기준)

`brand-dna.json` 참조 — 와이어프레임 단계에서 강제 적용:

- **컬러**: section_light `#FFFFFF` / section_tinted `#F2F4F7` / section_dark `#0B132D` / section_footer `#060C1F` 4단 교차
- **Accent**: `#2563EB` (blue) → `#00C8C8` (teal) 135° 그라디언트는 **Hero 1곳, X 심볼, 핵심 CTA 호버**에만 사용 (남용 금지)
- **타이포**: 한글 Pretendard / 영문 Inter / 코드 JetBrains Mono. `h_display` = clamp(40px, 6vw, 78px)
- **레이아웃**: max_width `1240px`, gutter `32px`, section_pad_y `120px` (모바일은 80px)
- **카드**: 24px gap, radius 12px, shadow는 라이트 섹션에서만 (다크 섹션은 1px line)

---

## 3. 페이지별 와이어프레임 (8개)

각 페이지는 다음 파일에 분리 보관:

| # | 페이지 | 파일 |
|---|---|---|
| W1 | `/` 랜딩 | [`01_landing.md`](./01_landing.md) |
| W2 | `/problem` | [`02_problem.md`](./02_problem.md) |
| W3 | `/solution` | [`03_solution.md`](./03_solution.md) |
| W4 | `/how-it-works` | [`04_how_it_works.md`](./04_how_it_works.md) ✅ |
| W5 | `/use-cases` | [`05_use_cases.md`](./05_use_cases.md) ✅ |
| W6 | `/pricing` | [`06_pricing.md`](./06_pricing.md) ✅ |
| W7 | `/platform-api` | [`07_platform_api.md`](./07_platform_api.md) ✅ |
| W8 | `/company` (+ team/vision/investors) | [`08_company.md`](./08_company.md) ✅ |

각 파일 공통 섹션:

1. **목표 & 청자** (어느 페르소나가 무엇을 가지고 떠나야 하는가)
2. **모바일 와이어 (360px 정본)** — ASCII
3. **데스크톱 와이어 (≥980px)** — ASCII 또는 컬럼 규칙
4. **컨텐츠 슬롯 / i18n 키** — `nav.problem`, `hero.headline_ko/en` 등
5. **인터랙션** — Stimulus 컨트롤러/모션 토큰
6. **LCP 예산** — Hero 자원 크기, 지연 로드 영역
7. **분석 이벤트** — `cta_*_click`, `*_submit`
8. **a11y** — 키보드 포커스, ARIA, 대비

---

## 4. 모바일 LCP < 2.5s 강제 룰 (모든 페이지 적용)

| 룰 | 적용 |
|---|---|
| Hero 이미지 X | SVG/CSS 그라디언트만. 사진 필요 시 below-fold + `loading="lazy"` |
| 폰트 로딩 | Pretendard/Inter는 `font-display: swap` + woff2 subset (한글 = `KS` 서브셋, 영문 = Latin) |
| Above-fold | 1차 페인트 자원 ≤ 100KB (HTML+CSS critical+SVG) |
| JS | Hotwire(Turbo+Stimulus)만, Hero용 JS 없음. 카운트업/탭은 below-fold |
| 이미지 | WebP + `width/height` 명시 (CLS 방지) |
| 다운로드 PDF | preload 금지, 사용자 클릭 시 fetch |
| 카운트업 | `IntersectionObserver`로 viewport 진입 시에만 |

---

## 5. 한/영 카피 처리 원칙

- **카피 = i18n 키만 표기**: 와이어프레임에는 한글 카피 예시 + 영문 미러 키 명시. 실제 텍스트는 `config/locales/{ko,en}/{page}.yml`로 관리.
- **번역 규칙** (PRD §6.4): 한글 1차 → LLM 번역 → CEO 검수.
- **단어 길이 차**: 영문이 평균 30% 길어짐 → Hero 헤드라인은 **2줄 가능한 길이**로 설계, 카드 헤더는 영문 기준 48자 한도.
- **숫자 표기**: 한국어 `₩30억` / 영문 `$2.3M` 별도 i18n 키. 자동 환산 금지 (피치덱 일관성).

---

## 6. 컴포넌트 인벤토리 (8 페이지 공통)

| 컴포넌트 | 사용 페이지 | ViewComponent 후보 |
|---|---|---|
| `NavBar` (sticky, 언어토글) | All | `NavComponent` |
| `Footer` | All | `FooterComponent` |
| `HeroDark` (그라디언트 + headline + dual CTA) | W1, W4, W7, W8/investors | `HeroDarkComponent` |
| `HeroLight` (eyebrow + h1 + lead) | W2, W3, W5, W6, W8/team, W8/vision | `HeroLightComponent` |
| `KPICard4` (숫자 카운트업) | W1, W5, W8/investors | `KpiGridComponent` |
| `MoatTriangle` (해자 삼각형 SVG) | W1, W3 | `MoatDiagramComponent` |
| `StepIndicator5` (5단계 워크플로우) | W1, W4 | `WorkflowStepsComponent` |
| `ScenarioTabs` (Bull/Base/Worst) | W6, W8/investors | `ScenarioTabsComponent` (Stimulus) |
| `CaseCard` (산업 사례) | W5 | `CaseCardComponent` |
| `PricingTier` (4단계) | W6 | `PricingTierComponent` |
| `CodeBlock` (MCP 예제) | W7 | `CodeBlockComponent` |
| `IRDownloadForm` (이메일 게이트) | W1 보조, W8/investors | `IrDownloadFormComponent` |
| `DemoCTA` (반복 CTA 슬랩) | All | `DemoCtaComponent` |
| `TeamCard` (인물) | W8/team | `TeamCardComponent` |
| `VisionPhase` (Phase 1/2/3) | W8/vision | `VisionPhaseComponent` |

---

## 7. 검증 계획 (CLAUDE.md 캐릭터 저니 연결)

와이어프레임이 구현 단계로 넘어가면 다음 5개 캐릭터 저니가 와이어프레임 정합성 검증을 책임진다.

| 캐릭터 | 통과해야 하는 와이어프레임 경로 |
|---|---|
| 김 상무 (제조 SME) | W1 → W2 → W5(제조 카드) → /contact |
| 박 사무관 (공공) | W1 → W5(공공 카드) → W8/investors |
| Sarah (MCP 개발자) | /en → W1(en) → W7 → W7 코드 복사 |
| Investor | W1 → W8/investors → IR PDF 다운로드 폼 |
| Admin | (별도 admin 와이어프레임 — 본 이슈 범위 외) |

→ M5 단계에서 Playwright 시나리오 5건이 각 와이어프레임 페이지의 핵심 요소를 click/screenshot으로 검증.

---

## 8. 다음 액션 (after merge)

1. 본 와이어프레임 + brand-dna 토큰을 기반으로 ViewComponent 스캐폴딩 이슈 분리 생성
2. ko/en i18n YAML 키 슬롯 채우기 (피치덱 카피 → ko, LLM 1차번역 → en)
3. M2 (Marketing Pages) 단계에서 W1 → W2 → W3 순으로 구현
4. 각 페이지 머지 직전 Lighthouse(mobile) 측정 → LCP < 2.5s 게이트

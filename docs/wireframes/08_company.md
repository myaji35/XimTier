# W8 — `/company` 회사 페이지 (한/영 미러, 3 서브페이지)

> 본 와이어프레임은 4개 라우트를 묶어서 보관한다 (PRD §3의 "8개 페이지" 카운트는 *전체 IA의 묶음 단위*로 1).
>
> | 서브 | 라우트 | 핵심 청자 |
> |---|---|---|
> | W8a | `/company` (인덱스, 옵션) | 모든 청자 — `/company/team` 등으로 분기 |
> | W8b | `/company/team` | Investor / 채용 후보 |
> | W8c | `/company/vision` | Investor / 파트너 |
> | W8d | `/company/investors` | Investor (IR PDF 다운로드 게이트) |
>
> 현재 `config/routes.rb`에 `/company` 인덱스 라우트는 없음 — IA 일관성을 위해 *옵션 라우트*로 명시하되, M2 단계에서 추가 여부 결정 (W8b/c/d 셋이 충분하면 생략 가능).

---

## W8a — `/company` (옵션 인덱스)

### 1. 목표
모든 청자가 회사 정보 3개(team / vision / investors)에 한눈에 진입.

### 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Light Hero)                             │
│ EYEBROW: 회사 / Company                  │
│ H1: "XimTier — Decision Intelligence,     │
│      Proven by Numbers"                  │
│ LEAD: "Gagahoho Inc. 제품. 서울 본사,      │
│        4개 산업에 적용 중."                 │
│                                          │
├─────────────────────────────────────────┤
│  3개 진입 카드                              │
│  ┌──────────────────────────────────────┐│
│  │ [icon: users]                         ││
│  │ Team                                  ││
│  │ "팔란티어·구글·삼성 출신 4인"           ││
│  │ → /company/team                      ││
│  └──────────────────────────────────────┘│
│  ┌──────────────────────────────────────┐│
│  │ [icon: compass]                       ││
│  │ Vision                                ││
│  │ "비전문가가 5분 안에 의사결정."          ││
│  │ → /company/vision                    ││
│  └──────────────────────────────────────┘│
│  ┌──────────────────────────────────────┐│
│  │ [icon: file-text]                     ││
│  │ Investors                             ││
│  │ "Pre-seed 라운드 진행 중. IR Deck."    ││
│  │ → /company/investors                 ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

### 3. 데스크톱 (≥980px)
- Hero + 3개 카드 1x3 grid

(인덱스 라우트는 옵션이므로 상세 i18n/이벤트는 본 와이어 생략)

---

## W8b — `/company/team`

### 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| Investor | "Founder-Market Fit 확실 + execution 능력" → `/company/investors` |
| 채용 후보 | "팔란티어 출신 + 한국 토양 = 흥미" → `/contact?topic=hiring` |
| 파트너 | "어드바이저 검증된 회사" → `/contact?topic=partnership` |

**핵심 전환**: IR Deck 다운로드 (`/company/investors`) / Contact.

### 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Light Hero)                             │
│ EYEBROW: 팀 / Team                       │
│ H1: "이걸 풀 수 있는 4인"                  │
│ LEAD: "팔란티어·구글·삼성 출신.             │
│        Decision Intelligence 30+년."     │
│                                          │
├─────────────────────────────────────────┤
│  Founder 카드 (CEO — 강조)                │
│  ┌──────────────────────────────────────┐│
│  │ [photo 100x100 round]                 ││
│  │ 강승식 / S. Kang                      ││
│  │ CEO & Founder                         ││
│  │                                       ││
│  │ "보험·핀테크 SaaS 2회 창업·매각.        ││
│  │  Vibe Coding으로 빠른 PMF 추구."        ││
│  │                                       ││
│  │ • Gagahoho Inc. 창립                   ││
│  │ • InsureGraph Pro / CertiGraph        ││
│  │ • SNU 통계학                           ││
│  │                                       ││
│  │ [LinkedIn ↗] [Twitter ↗]              ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤
│  TeamCard x 3 (CTO/Head of AI/Head of    │
│                Industry)                  │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [photo 80x80 round]                   ││
│  │ {이름} / CTO                          ││
│  │ "Ex-Palantir SDE. 7년 Foundry."        ││
│  │ • SCM/Manufacturing graph             ││
│  │ • Stanford CS                          ││
│  └──────────────────────────────────────┘│
│  (동일 패턴 x 2)                           │
│                                          │
├─────────────────────────────────────────┤  ← tinted
│  어드바이저 (Advisors)                     │
│  EYEBROW: Advisors                       │
│  H3: "전문성 보강"                          │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ {이름} — Industry Advisor              ││
│  │ "전 LG화학 CIO. 제조 데이터 30년."      ││
│  └──────────────────────────────────────┘│
│  (advisor 3~5인 카드 반복)                 │
│                                          │
├─────────────────────────────────────────┤
│  채용 슬랩 (We're hiring)                  │
│  H2: "함께 만들 사람을 찾습니다"             │
│  3개 직무 카드:                            │
│  • Senior Backend Engineer                │
│  • ML Research Engineer                   │
│  • Industry Solutions Lead                │
│  [Open positions →] (M4 단계)            │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

### 3. 데스크톱 (≥980px)
- Hero: 좌 카피 / 우 4인 그룹샷 placeholder (M2 단계에서 사진 결정)
- Founder 카드: full-width 2-col (좌 사진 / 우 카피)
- TeamCard 3: 1x3 grid
- 어드바이저: 1x3 또는 1x4 grid (수에 따라)
- 채용 슬랩: full-bleed 다크 + 3직무 1x3

### 4. i18n 키 슬롯
| 슬롯 | 키 |
|---|---|
| Hero | `team.hero.{h1,lead}` (ko/en) |
| Founder | `team.founder.{name,role,bio,credentials}` (ko/en) |
| Members N | `team.members.{cto,ai,industry}.{name,role,bio,credentials}` |
| Advisor N | `team.advisors[]` (배열, 각 `{name,role,bio}`) |
| Hiring slab | `team.hiring.{h2,positions[]}` |

**한/영 처리**:
- 이름: 한글 페이지 = `강승식 / S. Kang` (병기), 영문 페이지 = `S. Kang`만 (자국화 X, 인물 정체성 보존).
- 경력 cred: 영문 회사명은 양 페이지 동일 (Palantir / Google / Samsung).
- bio: 한글 → 영문 미러 카피 (LLM 번역 + CEO 검수, PRD §6.4).

### 5. 인터랙션
| 요소 | 동작 |
|---|---|
| 사진 hover (데스크톱) | grayscale 0 → 1.0 transition (개성 표출) |
| LinkedIn/Twitter | 새창, `rel="noopener noreferrer"` |
| 채용 직무 카드 hover | lift -2px |

### 6. LCP 예산
- 사진은 **WebP + width/height 명시 + lazy loading** (Founder만 above-fold, 나머지 lazy)
- Founder 사진 ≤ 30KB (100x100 retina)
- TeamCard 사진 ≤ 18KB each (80x80 retina)
- Above-fold: Hero + Founder 카드 < 130KB (사진 포함)
- Advisor/Hiring 슬랩은 below-fold lazy

### 7. 분석 이벤트
- `team_page_view`
- `team_member_view` (member_id payload)
- `team_member_link_click` (member_id, platform=linkedin/twitter)
- `hiring_position_click` (position_id)
- `lang_toggle` (page=team)

### 8. a11y
- TeamCard = `<article>` + `<h3>` (member 이름)
- 사진 `alt="강승식 (CEO & Founder) 인물 사진"` 명시
- 외부 링크 `aria-label="강승식의 LinkedIn (새 창)"`
- 채용 카드는 `<a>` 전체 wrap
- 키보드: Tab으로 모든 인물 카드 + 외부 링크 도달

---

## W8c — `/company/vision`

### 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| Investor | "10년 비전이 명확 + Phase별 사다리" → `/company/investors` |
| 김 상무 (SME) | "회사 방향이 우리 산업과 충돌 안 함" → `/use-cases` |

**핵심 전환**: IR Deck 다운로드 / Demo.

### 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Dark Hero — 그라디언트, vision 톤)       │
│ EYEBROW: 비전 / Vision                   │
│ H1: "비전문가가 5분 안에 의사결정"           │
│ LEAD: "팔란티어가 풀지 못한 '한국형         │
│        엔터프라이즈 결정'을 푼다."            │
│                                          │
├─────────────────────────────────────────┤
│  미션 (Mission) 카드                       │
│  H2: "왜 우리가 만드는가"                  │
│  BODY: "복잡한 데이터를 두려워하지 않는      │
│        의사결정자를 만든다. 데이터는 비반출,│
│        결과는 설명 가능."                  │
│                                          │
├─────────────────────────────────────────┤  ← tinted
│  Phase 로드맵 (Phase 1/2/3)                │
│  EYEBROW: Roadmap                        │
│  H2: "10년, 3단계"                          │
│                                          │
│  ┌─ PHASE 1 (2026~2027) ──────────────┐ │
│  │ Decision Intelligence SaaS          │ │
│  │ "4개 수직(제조/병원/공공/스마트시티) │ │
│  │  PMF + ARR ₩50억"                  │ │
│  │ • 운영 콘솔 + Reverse What-If       │ │
│  │ • MCP/Plugin SDK 정착               │ │
│  │ • Pre-seed → Seed                   │ │
│  └────────────────────────────────────┘ │
│  ┌─ PHASE 2 (2028~2030) ──────────────┐ │
│  │ Industry Ontology Layer             │ │
│  │ "수직별 ontology + Reverse What-If │ │
│  │  marketplace. Series A."             │ │
│  │ • 산업 ontology 5종 표준화           │ │
│  │ • Plugin marketplace 1k 인스톨      │ │
│  │ • Multi-region GA                   │ │
│  └────────────────────────────────────┘ │
│  ┌─ PHASE 3 (2031~) ──────────────────┐ │
│  │ Operating System for Decisions      │ │
│  │ "MCP/Agent ecosystem 허브.           │ │
│  │  Palantir-급 OS. Series B/C."        │ │
│  │ • OS-grade 운영 콘솔                │ │
│  │ • Agent marketplace                 │ │
│  │ • Asia-Pacific 헤드쿼터              │ │
│  └────────────────────────────────────┘ │
│                                          │
├─────────────────────────────────────────┤
│  4 신념 (4 Beliefs)                       │
│  H3: "우리가 믿는 것"                      │
│  1. 결정은 설명 가능해야 한다.              │
│  2. 데이터는 회사 안에 머문다.               │
│  3. 비전문가가 5분 안에 풀 수 있어야 한다.    │
│  4. 한국 시장은 글로벌 검증의 시작이다.      │
│                                          │
├─────────────────────────────────────────┤  ← CTA
│  H2: "이 비전에 동참하는 법"                │
│  [Read IR Deck →] (primary)              │
│  [Join us →] (secondary, /company/team)  │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

### 3. 데스크톱 (≥980px)
- Hero: 좌 카피 / 우 vision 일러스트 (SVG only, CSS 그라디언트 +기하 도형)
- Phase 3개: 1x3 grid (모바일은 1x3 세로 적층)
- 4 신념: 2x2 grid (모바일은 1x4)
- CTA: full-bleed 다크

Phase 카드 디자인:
- Phase 1 = 라이트 카드 + 진행 중 배지 (`In progress`)
- Phase 2 = 라이트 카드 + 점선 stroke (`Next`)
- Phase 3 = 어둡게 + 미래 톤 (`Future`)

### 4. i18n 키 슬롯
| 슬롯 | 키 |
|---|---|
| Hero | `vision.hero.{h1,lead}` |
| Mission | `vision.mission.{h2,body}` |
| Phase N | `vision.phase.{1,2,3}.{period,title,desc,items[]}` |
| Belief N | `vision.beliefs[]` (4개 배열) |
| CTA | `vision.cta.{h2,primary,secondary}` |

**한/영 처리**:
- Phase 명칭은 한/영 별도 키. 한글 "운영 콘솔" / 영문 "Operations Console" 등.
- 연도 표기 동일 (2026~2027).
- ARR 금액: 한글 `₩50억` / 영문 `$3.8M ARR` — 자동 환산 금지.

### 5. 인터랙션
| 요소 | 동작 |
|---|---|
| Phase 카드 진입 | viewport 진입 시 fade-up 80ms stagger |
| In progress 배지 | 미세 pulse (1.0 → 1.04 → 1.0, 1.6s loop) |
| 4 신념 | 진입 시 number 카운터 fade-in (각 250ms) |

### 6. LCP 예산
- Above-fold: Hero(다크 그라디언트) ≤ 80KB
- Phase 일러스트 X — 텍스트 카드만
- 사진 X
- vision SVG 일러스트(데스크톱 only) < 8KB

### 7. 분석 이벤트
- `vision_page_view`
- `phase_card_view` (phase 1/2/3)
- `cta_ir_deck_click` (`from=vision`)
- `cta_join_click` (`from=vision`)
- `lang_toggle` (page=vision)

### 8. a11y
- Phase 3개 = `<ol>` semantic (순서 있음)
- In progress 배지 = `<span role="status">` (스크린리더 알림 친화)
- 4 신념 = `<ol>` (순서)
- Phase 일러스트 SVG는 `aria-hidden="true"` (장식)
- 키보드: Tab으로 CTA 도달, Phase 카드는 비대화 요소(읽기 전용)

---

## W8d — `/company/investors` (IR PDF 다운로드 게이트)

### 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| Investor | "이메일 입력 → IR PDF 다운로드" → 후속 미팅 요청 |
| Internal | "Lead가 자동 캡처되어 Slack/Admin에 알림" |

**핵심 전환**: 이메일 + 회사 입력 → 토큰 발급 → PDF 다운로드 + Admin 알림.
이미 구현됨 (XIM-15 done). 본 와이어는 *디자인/카피/UX 사양*만 명시.

### 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier         [KO|EN] [Demo→]   │
├─────────────────────────────────────────┤
│ (Dark Hero — IR 톤, 진중함)              │
│ EYEBROW: Investors                       │
│ H1: "Pre-seed Round, 2026"               │
│ LEAD: "$X.XM raising / Lead investor     │
│        있음 / 5개 좌석 남음."             │
│                                          │
├─────────────────────────────────────────┤
│  KPI 4 카드 (Pitch summary)                │
│  ┌─────────┬─────────┬─────────┬───────┐│
│  │ ₩42억   │ 12 PoC   │ 87%     │ 4 산업││
│  │ pipeline│ active   │ XAI cov.│ live  ││
│  └─────────┴─────────┴─────────┴───────┘│
│                                          │
├─────────────────────────────────────────┤  ← light section
│  IR Deck 다운로드 폼 (이메일 게이트)        │
│  H2: "IR Deck (PDF, 24p)"                │
│  LEAD: "이메일을 남기면 토큰 링크로          │
│        24시간 안에 다운로드 가능."          │
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ [이름 *]            [_______________]││
│  │ [회사 *]            [_______________]││
│  │ [이메일 *]          [_______________]││
│  │ [직책]              [_______________]││
│  │ [국가] [▼ South Korea / US / Other]  ││
│  │ [✓] 개인정보 처리방침에 동의 *         ││
│  │ [✓] 마케팅 수신 동의 (optional)        ││
│  │                                       ││
│  │ [Send me the deck →] (primary)        ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← tinted
│  주요 자료 (Quick links)                   │
│  • 1-pager (영문, 외부 공유 가능)           │
│  • Market Map (`/company/market`)         │
│  • Reverse What-If 데모 비디오 (3분)        │
│  • 캐릭터별 use case PDF (4종)              │
│  (각 항목 → 별도 토큰 또는 공개 링크)        │
│                                          │
├─────────────────────────────────────────┤  ← dark
│  Investor FAQ (5개 accordion)              │
│  ▸ Pre-seed 라운드 규모?                    │
│  ▸ Use of funds?                          │
│  ▸ Founder equity 구조?                    │
│  ▸ 기존 투자자/어드바이저?                   │
│  ▸ Path to ARR ₩50억?                       │
│                                          │
├─────────────────────────────────────────┤
│  Contact founder 슬랩                      │
│  H3: "직접 대화"                            │
│  "강승식 (CEO) — kss@xaisimtier.ai"        │
│  "Calendly 30분 슬롯 → [Book →]"           │
│                                          │
├─────────────────────────────────────────┤
│  Footer                                   │
└─────────────────────────────────────────┘
```

### 3. 데스크톱 (≥980px)
- Hero: 좌 60% 카피 / 우 40% KPI 4 카드 (그리드 2x2)
- IR Deck 폼: 중앙 정렬 max-width 560px, 좌 라벨 / 우 입력 (1x6 row)
- Quick links: 1x4 카드 grid
- Investor FAQ: 2-col accordion
- Contact founder: full-bleed 다크 + Calendly 임베드 (lazy)

### 4. i18n 키 슬롯
| 슬롯 | 키 |
|---|---|
| Hero | `investors.hero.{eyebrow,h1,lead}` |
| KPI 4 | `investors.kpi.{pipeline,poc,xai,verticals}_ko/en` (숫자 별도) |
| Form labels | `investors.form.{name,company,email,role,country,consent_privacy,consent_marketing}` |
| Form submit | `investors.form.submit` ("Send me the deck") |
| Quick links | `investors.quick_links[]` |
| FAQ items | `investors.faq[]` (5개 `{q,a}`) |
| Contact founder | `investors.contact.{h3,email,calendly_label}` |

**한/영 처리**:
- 폼 라벨 한/영 미러.
- 동의 문구는 법무 검토 후 ko=한국 PIPA / en=GDPR 친화 카피 (별도 키, 자동 번역 X).
- KPI 숫자는 PRD §6.4 그대로 (₩42억 / $3.2M 등).

### 5. 인터랙션
| 요소 | 동작 |
|---|---|
| 폼 submit | DemoRequestsController → 토큰 생성 → 이메일 발송 → 토큰 URL `/ir/:token` 자동 페이지 이동 (구현됨 XIM-15) |
| 필수값 누락 | Rails validation → form re-render with error (inline 에러 메시지) |
| consent_privacy 미체크 | submit disabled |
| 토큰 만료 | `/ir/:token` 진입 시 "토큰이 만료되었습니다" + 폼 재제출 안내 |
| Calendly | iframe lazy load (IntersectionObserver) |

### 6. LCP 예산
- Above-fold: Hero + KPI 4 카드 + 폼 첫 3 필드 ≤ 95KB
- Calendly iframe은 below-fold lazy (사용자 클릭으로 트리거)
- 폼은 native HTML5 + Stimulus validation, JS < 8KB
- IR PDF 자체는 토큰 발급 후 별도 페이지에서 다운로드 (preload 금지)

### 7. 분석 이벤트
| 이벤트 | 트리거 |
|---|---|
| `investors_page_view` | 페이지 로드 |
| `ir_form_start` | 폼 첫 필드 focus |
| `ir_form_submit` | 폼 제출 (email_domain payload, PII 마스킹) |
| `ir_form_validation_error` | validation fail (field payload) |
| `ir_download_click` | `/ir/:token` 페이지 PDF 링크 클릭 |
| `quick_link_click` | quick link 카드 클릭 (slug) |
| `faq_open` | FAQ 펼침 (faq_id) |
| `calendly_open` | Calendly 임베드 활성화 |
| `cta_email_founder_click` | Founder 이메일 mailto 클릭 |

→ Investor 캐릭터 저니의 핵심: `investors_page_view → ir_form_submit → ir_download_click` 깔때기. M5 단계 Playwright 검증.

### 8. a11y
- 폼 라벨 `<label for>` 명시
- 필수값 `aria-required="true"`
- validation 에러 `aria-describedby` + `<span role="alert">`
- 동의 체크박스는 `<label>` wrap (전체 텍스트 클릭 가능)
- KPI 4 카드는 `<dl>` (term=metric label, dd=value)
- Calendly iframe `title="Calendly 미팅 예약"`
- 키보드: Tab으로 필드 → 동의 체크박스 → 제출 버튼 순
- 대비: 다크 Hero 위 LEAD 텍스트 #E2E8F0 / 라이트 폼 위 라벨 #0B132D — WCAG AA 통과

---

## 모든 W8 서브페이지 공통 — 검증 매트릭스 연결

| 캐릭터 저니 (XIM-21) | 핵심 와이어 |
|---|---|
| Investor | W8d (IR 폼) + W8c (Phase) + W8b (Team) |
| 박 사무관 (공공) | W8d (보조 — Phase Phase 2 공공) |
| 김 상무 (제조) | W8c (Phase 1 PMF 확인) |
| Sarah (개발자) | W8b (CTO 배경 검증) + W8a (전체 인덱스) |

M5 단계 Playwright 스크린샷:
- `/company/team` (모바일 360px, 데스크톱 1280px)
- `/company/vision` (Phase 카드 viewport 진입 후)
- `/company/investors` (폼 작성 → 제출 → `/ir/:token` 도착)

---

## 다음 액션 (after merge)

1. `/company` 인덱스 라우트(W8a) 추가 여부 결정 — M2 단계 product-manager가 판단
2. `team.yml` / `vision.yml` / `investors.yml` i18n YAML 슬롯 채우기
3. TeamCard / VisionPhase / IRDownloadForm ViewComponent 스캐폴딩 이슈 분리 생성 (이미 IRDownloadForm은 XIM-15에서 일부 구현됨 — 매핑 점검 필요)
4. Founder 사진 + Team 사진 에셋 결정 (M2 단계)
5. Phase 일러스트 SVG 디자인 (XIM-12 해자 SVG와 일관성)

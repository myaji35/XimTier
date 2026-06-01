# XimTier /deck 시안 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 한일 대표 PPTX(76장)의 메뉴 구성·문구·의도를 충실히 반영한 별도 홈페이지 시안을 `/(:locale)/deck` 경로에 구현한다. 현 `ximtier.com` 홈은 일절 수정하지 않는다.

**Architecture:** Rails 정적 콘텐츠 페이지. `pages#deck` 액션 1개 + deck 전용 뷰/파셜(nav + 5챕터) + ko/en i18n(deck.yml). 원페이지 스크롤 + 상단 5대메뉴 앵커 네비. 하이브리드 디자인(강조부 다크 네이비 + 본문 화이트). deck 전용 CSS는 인라인 `<style>`로 격리하여 기존 스타일 비오염.

**Tech Stack:** Rails 8.1, ERB, i18n(YAML), Tailwind(기존), 인라인 CSS. 검증은 HTTP 200 + 콘텐츠 grep + Playwright 스크린샷.

---

## File Structure

| 파일 | 책임 | 신규/수정 |
|---|---|---|
| `config/routes.rb` | `/deck` 라우트 1줄 추가 | 수정 (기존 scope 블록 안) |
| `app/controllers/pages_controller.rb` | `def deck; end` 액션 추가 | 수정 |
| `app/views/pages/deck.html.erb` | 컨테이너: deck 전용 CSS + nav + 5챕터 파셜 렌더 | 신규 |
| `app/views/pages/deck/_nav.html.erb` | 상단 5대메뉴 앵커 네비 | 신규 |
| `app/views/pages/deck/_chapter_overview.html.erb` | 01 메뉴 구성 개요 (Hero 포함) | 신규 |
| `app/views/pages/deck/_chapter_data.html.erb` | 02 데이터 탐색 8종 | 신규 |
| `app/views/pages/deck/_chapter_analysis.html.erb` | 03 AI 통계분석 (파이프라인·4종·Xim4Reporting) | 신규 |
| `app/views/pages/deck/_chapter_solutions.html.erb` | 04 One-Stop 10종 | 신규 |
| `app/views/pages/deck/_chapter_usage.html.erb` | 05 업무 활용 방안 | 신규 |
| `config/locales/ko/deck.yml` | 한국어 콘텐츠(PPTX 원문) | 신규 |
| `config/locales/en/deck.yml` | 영어 콘텐츠 | 신규 |

**격리 원칙:** home 관련 파일(`home.html.erb`, `site.yml`)은 절대 수정하지 않는다. deck.yml 네임스페이스 최상위 키는 `deck:`.

---

### Task 1: 라우트 + 컨트롤러 액션 + 빈 뷰 (스캐폴드)

**Files:**
- Modify: `config/routes.rb` (기존 `scope "(:locale)"` 블록 안, `get "/", to: "pages#home"` 근처)
- Modify: `app/controllers/pages_controller.rb`
- Create: `app/views/pages/deck.html.erb`

- [ ] **Step 1: 라우트 추가**

`config/routes.rb`에서 `get "/", to: "pages#home", as: :home` 줄을 찾아 그 아래에 추가:

```ruby
    get "/deck", to: "pages#deck", as: :deck
```

- [ ] **Step 2: 컨트롤러 액션 추가**

`app/controllers/pages_controller.rb`에서 `def home; end` 아래에 추가:

```ruby
  def deck; end
```

- [ ] **Step 3: 최소 뷰 생성**

`app/views/pages/deck.html.erb`:

```erb
<% content_for :title, "XimTier — 메뉴 구성과 구현 화면" %>
<h1>DECK PLACEHOLDER</h1>
```

- [ ] **Step 4: 서버 200 검증**

Run (서버가 3022에 떠 있음, 없으면 `bin/rails server -p 3022 -b 127.0.0.1` 먼저):
```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3022/ko/deck
```
Expected: `200`

추가 검증 (콘텐츠 확인):
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -c "DECK PLACEHOLDER"
```
Expected: `1`

- [ ] **Step 5: 회귀 검증 (현 홈 무변경)**

```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3022/ko
```
Expected: `200` (기존 홈 정상)

- [ ] **Step 6: Commit**

```bash
git add config/routes.rb app/controllers/pages_controller.rb app/views/pages/deck.html.erb
git commit -m "feat(deck): /deck 라우트+액션+빈 뷰 스캐폴드"
```

---

### Task 2: ko/en deck.yml i18n 스켈레톤 (5챕터 메뉴 키)

**Files:**
- Create: `config/locales/ko/deck.yml`
- Create: `config/locales/en/deck.yml`

- [ ] **Step 1: ko/deck.yml 생성 (사이트맵 + Hero 핵심 문구)**

`config/locales/ko/deck.yml`:

```yaml
ko:
  deck:
    brand: XimTier
    brand_sub: Explainable AI Simulation frontier
    hero:
      eyebrow: "AI 의사결정 최적화 플랫폼"
      title_top: "분석이 아니라"
      title_accent: "의사결정 최적화"
      lead: "데이터 탐색 → AI 분석 → What-If·Reverse What-If 최적화 → 자동 보고서 → AI Q&A까지 한 번에 수행하는 One-Stop AI 의사결정 플랫폼"
      cta_demo: "데모 신청"
      cta_contact: "문의하기"
    nav:
      overview: "메뉴 구성 개요"
      data: "데이터 탐색"
      analysis: "AI 통계분석"
      solutions: "One-Stop 솔루션"
      usage: "업무 활용"
    chapters:
      overview:
        no: "01"
        title: "메뉴 구성 개요"
        items: ["주요 메뉴 구성 개요", "XimTier 특징 요약", "XimTier 핵심 기술력", "메뉴 요약", "기술 구조와 서비스 방식", "XimTier 최적화 로드맵", "XimTier 활용과 효과"]
      data:
        no: "02"
        title: "데이터 탐색"
        items: ["데이터 탐색", "WhatDataAI 분석", "주소 XY 정제", "AI 탐색 차트", "AI 텍스트 탐색 분석", "주제도 분석", "AI 종합 인사이트 리포트", "AI Target YX 최적화"]
      analysis:
        no: "03"
        title: "AI 통계분석 솔루션"
        items: ["AI 분석 파이프라인", "AI 분석 종류와 방법", "Xim4Reporting"]
      solutions:
        no: "04"
        title: "AI One-Stop 솔루션"
        items: ["AI 스마트 Meeting 분석", "AI 스마트 설문 분석", "AI 스마트 SNS 분석", "AI 축제/행사 YX 최적화", "AI 전통시장/상권 YX 최적화", "AI 소상공인/매장 YX 최적화", "AI 광고형 병의원 YX 최적화", "AI 설비고장/예지보전 YX 최적화", "AI SNS 기반 제품 기능 개발 YX 최적화", "AI 설문 기반 제품 기능 개발 YX 최적화"]
      usage:
        no: "05"
        title: "업무 활용 방안"
        items: ["AX 활용성 강화 방안", "데이터 기반의 AI 의사결정 플랫폼", "분야별 활용과 기대효과", "맞춤형 서비스 방안"]
```

- [ ] **Step 2: en/deck.yml 생성 (동일 구조 영문)**

`config/locales/en/deck.yml`:

```yaml
en:
  deck:
    brand: XimTier
    brand_sub: Explainable AI Simulation frontier
    hero:
      eyebrow: "AI Decision Optimization Platform"
      title_top: "Not analysis, but"
      title_accent: "Decision Optimization"
      lead: "A One-Stop AI decision platform: data exploration → AI analysis → What-If / Reverse What-If optimization → auto reports → AI Q&A, all in one flow."
      cta_demo: "Request a demo"
      cta_contact: "Contact us"
    nav:
      overview: "Overview"
      data: "Data Exploration"
      analysis: "AI Analytics"
      solutions: "One-Stop Solutions"
      usage: "Use Cases"
    chapters:
      overview:
        no: "01"
        title: "Menu Overview"
        items: ["Menu structure overview", "XimTier highlights", "Core technology", "Menu summary", "Architecture & service model", "Optimization roadmap", "Impact & outcomes"]
      data:
        no: "02"
        title: "Data Exploration"
        items: ["Data exploration", "WhatDataAI analysis", "Address XY cleansing", "AI exploratory charts", "AI text exploration", "Thematic map analysis", "AI insight report", "AI Target YX optimization"]
      analysis:
        no: "03"
        title: "AI Analytics Solution"
        items: ["AI analysis pipeline", "Analysis types & methods", "Xim4Reporting"]
      solutions:
        no: "04"
        title: "AI One-Stop Solutions"
        items: ["AI Smart Meeting analysis", "AI Smart survey analysis", "AI Smart SNS analysis", "AI Festival/Event YX optimization", "AI Traditional market/Retail YX optimization", "AI Small business/Store YX optimization", "AI Ad-driven clinic YX optimization", "AI Equipment failure/Predictive maintenance YX optimization", "AI SNS-based product development YX optimization", "AI Survey-based product development YX optimization"]
      usage:
        no: "05"
        title: "Use Cases"
        items: ["AX adoption enablement", "Data-driven AI decision platform", "Impact by domain", "Custom service approach"]
```

- [ ] **Step 3: YAML 문법 검증**

Run:
```bash
ruby -ryaml -e "YAML.load_file('config/locales/ko/deck.yml'); YAML.load_file('config/locales/en/deck.yml'); puts 'OK'"
```
Expected: `OK`

- [ ] **Step 4: i18n 로드 검증 (서버 재시작 후)**

deck.yml은 신규 파일이라 서버 재시작 필요. 재시작 후:
```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3022/ko/deck
```
Expected: `200`

- [ ] **Step 5: Commit**

```bash
git add config/locales/ko/deck.yml config/locales/en/deck.yml
git commit -m "feat(deck): ko/en deck.yml i18n (5챕터 사이트맵 + Hero)"
```

---

### Task 3: 컨테이너 뷰 + deck 전용 CSS + nav 파셜

**Files:**
- Modify: `app/views/pages/deck.html.erb` (전체 교체)
- Create: `app/views/pages/deck/_nav.html.erb`

- [ ] **Step 1: nav 파셜 생성 (상단 5대메뉴 앵커)**

`app/views/pages/deck/_nav.html.erb`:

```erb
<nav class="deck-nav">
  <div class="deck-nav-inner">
    <a href="#deck-top" class="deck-brand"><%= t("deck.brand") %></a>
    <div class="deck-nav-links">
      <a href="#overview"><%= t("deck.nav.overview") %></a>
      <a href="#data"><%= t("deck.nav.data") %></a>
      <a href="#analysis"><%= t("deck.nav.analysis") %></a>
      <a href="#solutions"><%= t("deck.nav.solutions") %></a>
      <a href="#usage"><%= t("deck.nav.usage") %></a>
    </div>
    <a href="<%= demo_path(locale: I18n.locale) %>" class="deck-cta"><%= t("deck.hero.cta_demo") %></a>
  </div>
</nav>
```

- [ ] **Step 2: 컨테이너 뷰 전체 교체 (CSS + nav + 챕터 렌더 슬롯)**

`app/views/pages/deck.html.erb` 전체를 교체:

```erb
<% content_for :title, "XimTier — 메뉴 구성과 구현 화면" %>

<style>
  .deck-root { --navy:#0a1124; --navy2:#16325C; --teal:#00C8C8; --blue:#2563EB; scroll-behavior:smooth; }
  .deck-root * { box-sizing:border-box; }
  .deck-nav { position:sticky; top:0; z-index:50; background:rgba(10,17,36,0.92); backdrop-filter:blur(8px); border-bottom:1px solid rgba(255,255,255,0.08); }
  .deck-nav-inner { max-width:1140px; margin:0 auto; display:flex; align-items:center; gap:24px; padding:14px 20px; }
  .deck-brand { color:#fff; font-weight:800; font-size:18px; text-decoration:none; letter-spacing:-0.3px; }
  .deck-nav-links { display:flex; gap:18px; margin-left:8px; flex:1; flex-wrap:wrap; }
  .deck-nav-links a { color:#a7b1c7; text-decoration:none; font-size:13px; font-weight:600; }
  .deck-nav-links a:hover { color:#00C8C8; }
  .deck-cta { background:linear-gradient(135deg,var(--blue),var(--teal)); color:#fff; padding:8px 16px; border-radius:8px; text-decoration:none; font-size:13px; font-weight:700; white-space:nowrap; }
  .deck-section { scroll-margin-top:70px; }
  .deck-dark { background:var(--navy); color:#fff; padding:80px 0; }
  .deck-light { background:#fff; color:#222; padding:72px 0; }
  .deck-wrap { max-width:1140px; margin:0 auto; padding:0 20px; }
  .deck-eyebrow { font-family:ui-monospace,monospace; font-size:12px; letter-spacing:2px; color:var(--teal); }
  .deck-h2 { font-size:30px; font-weight:800; line-height:1.2; margin:10px 0 0; word-break:keep-all; }
  .deck-dark .deck-h2 { color:#fff; }
  .deck-grad { background:linear-gradient(135deg,var(--blue),var(--teal)); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
  .deck-lead { font-size:16px; line-height:1.6; margin-top:16px; max-width:780px; }
  .deck-dark .deck-lead { color:#a7b1c7; }
  .deck-light .deck-lead { color:#3f3f3f; }
  .deck-chapter-no { display:inline-block; background:var(--teal); color:var(--navy); font-weight:800; font-size:12px; padding:3px 10px; border-radius:4px; }
  .deck-grid { display:grid; gap:16px; margin-top:32px; }
  .deck-grid-2 { grid-template-columns:repeat(2,1fr); }
  .deck-grid-3 { grid-template-columns:repeat(3,1fr); }
  .deck-grid-4 { grid-template-columns:repeat(4,1fr); }
  .deck-card { border:1px solid #ececec; border-radius:12px; padding:20px; background:#fff; }
  .deck-card-num { font-family:ui-monospace,monospace; font-size:11px; color:var(--blue); font-weight:700; }
  .deck-card-title { font-size:15px; font-weight:700; margin-top:6px; color:#222; }
  .deck-card-desc { font-size:12.5px; color:#717171; line-height:1.55; margin-top:6px; }
  .deck-dark .deck-card { background:rgba(255,255,255,0.04); border-color:rgba(255,255,255,0.1); }
  .deck-dark .deck-card-title { color:#fff; }
  .deck-dark .deck-card-desc { color:#a7b1c7; }
  .deck-hero { background:radial-gradient(800px 500px at 80% 10%, rgba(0,200,200,0.12), transparent 60%), var(--navy); padding:110px 0 90px; }
  .deck-hero-title { font-size:46px; font-weight:800; line-height:1.12; color:#fff; word-break:keep-all; }
  .deck-hero-cta { display:inline-flex; gap:12px; margin-top:28px; }
  .deck-btn-primary { background:linear-gradient(135deg,var(--blue),var(--teal)); color:#fff; padding:13px 26px; border-radius:10px; text-decoration:none; font-weight:700; }
  .deck-btn-ghost { border:1px solid rgba(255,255,255,0.3); color:#fff; padding:13px 26px; border-radius:10px; text-decoration:none; font-weight:600; }
  @media (max-width:820px){ .deck-grid-2,.deck-grid-3,.deck-grid-4{grid-template-columns:1fr;} .deck-hero-title{font-size:32px;} .deck-nav-links{display:none;} }
</style>

<div class="deck-root" id="deck-top">
  <%= render "pages/deck/nav" %>
  <%= render "pages/deck/chapter_overview" %>
  <%= render "pages/deck/chapter_data" %>
  <%= render "pages/deck/chapter_analysis" %>
  <%= render "pages/deck/chapter_solutions" %>
  <%= render "pages/deck/chapter_usage" %>
</div>
```

- [ ] **Step 3: 빈 챕터 파셜 5개 임시 생성 (렌더 에러 방지)**

다음 5개 파일을 각각 임시 콘텐츠로 생성 (Task 4~8에서 채움):

`app/views/pages/deck/_chapter_overview.html.erb`:
```erb
<section id="overview" class="deck-section"><!-- Task 4 --></section>
```
`app/views/pages/deck/_chapter_data.html.erb`:
```erb
<section id="data" class="deck-section"><!-- Task 5 --></section>
```
`app/views/pages/deck/_chapter_analysis.html.erb`:
```erb
<section id="analysis" class="deck-section"><!-- Task 6 --></section>
```
`app/views/pages/deck/_chapter_solutions.html.erb`:
```erb
<section id="solutions" class="deck-section"><!-- Task 7 --></section>
```
`app/views/pages/deck/_chapter_usage.html.erb`:
```erb
<section id="usage" class="deck-section"><!-- Task 8 --></section>
```

- [ ] **Step 4: 렌더 검증**

Run:
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE 'deck-nav|id="overview"|id="usage"'
```
Expected: `3` 이상

- [ ] **Step 5: Commit**

```bash
git add app/views/pages/deck.html.erb app/views/pages/deck/
git commit -m "feat(deck): 컨테이너 뷰 + deck 전용 CSS + nav 파셜 + 빈 챕터 슬롯"
```

---

### Task 4: 01 메뉴 구성 개요 챕터 (Hero + 핵심 콘텐츠)

**Files:**
- Modify: `app/views/pages/deck/_chapter_overview.html.erb` (전체 교체)

- [ ] **Step 1: Hero + 개요 콘텐츠 작성**

`app/views/pages/deck/_chapter_overview.html.erb` 전체 교체:

```erb
<%# Hero %>
<section class="deck-hero deck-section" id="overview">
  <div class="deck-wrap">
    <div class="deck-eyebrow">// <%= t("deck.hero.eyebrow") %></div>
    <h1 class="deck-hero-title">
      <%= t("deck.hero.title_top") %>
      <span class="deck-grad"><%= t("deck.hero.title_accent") %></span>
    </h1>
    <p class="deck-lead" style="color:#a7b1c7;"><%= t("deck.hero.lead") %></p>
    <div class="deck-hero-cta">
      <a href="<%= demo_path(locale: I18n.locale) %>" class="deck-btn-primary"><%= t("deck.hero.cta_demo") %></a>
      <a href="<%= contact_path(locale: I18n.locale) %>" class="deck-btn-ghost"><%= t("deck.hero.cta_contact") %></a>
    </div>
  </div>
</section>

<%# 01 메뉴 구성 개요 — 3단 아키텍처 + 로드맵 요약 %>
<section class="deck-dark">
  <div class="deck-wrap">
    <span class="deck-chapter-no"><%= t("deck.chapters.overview.no") %></span>
    <h2 class="deck-h2" style="margin-top:12px;"><%= t("deck.chapters.overview.title") %></h2>
    <div class="deck-grid deck-grid-3">
      <% t("deck.chapters.overview.items").each_with_index do |item, i| %>
        <div class="deck-card">
          <div class="deck-card-num"><%= "%02d" % (i+1) %></div>
          <div class="deck-card-title"><%= item %></div>
        </div>
      <% end %>
    </div>
  </div>
</section>
```

- [ ] **Step 2: 렌더 + 핵심 문구 검증**

Run:
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE '의사결정 최적화|기술 구조와 서비스 방식|최적화 로드맵'
```
Expected: `3` 이상

- [ ] **Step 3: Commit**

```bash
git add app/views/pages/deck/_chapter_overview.html.erb
git commit -m "feat(deck): 01 메뉴 구성 개요 챕터 + Hero"
```

---

### Task 5: 02 데이터 탐색 챕터 (8종 메뉴)

**Files:**
- Modify: `app/views/pages/deck/_chapter_data.html.erb` (전체 교체)
- Modify: `config/locales/ko/deck.yml` + `en/deck.yml` (각 메뉴 1줄 설명 추가)

- [ ] **Step 1: ko/deck.yml에 data 메뉴 설명 추가**

`config/locales/ko/deck.yml`의 `chapters: data:` 블록에 `descs:` 키 추가 (items와 같은 순서, 8개):

```yaml
      data:
        no: "02"
        title: "데이터 탐색"
        items: ["데이터 탐색", "WhatDataAI 분석", "주소 XY 정제", "AI 탐색 차트", "AI 텍스트 탐색 분석", "주제도 분석", "AI 종합 인사이트 리포트", "AI Target YX 최적화"]
        descs:
          - "로딩 데이터의 기초·기술 통계와 상관관계 히트맵 지원"
          - "활용 가능 AI 알고리즘(회귀·판별·다중분류·시계열)과 X·Y 변수 자동 추천"
          - "카카오 API + 내부 학습 주소 기반 위경도 좌표·행정구역 표준 파싱"
          - "기본형·분포통계·관계분석·고급시각화 등 개별 24종 / 자동 22종 차트"
          - "테이블·비정형 문서 워드클라우드 분석으로 텍스트 이해도 제고"
          - "행정경계 5종·격자/헥사곤 7종, VWorld·오픈스트리트맵 주제도"
          - "지식그래프 기반 자연어 질의 → 차트·주제도·시사점·정책 제언 자동 리포트 (No 환각)"
          - "60종 알고리즘 경쟁 + What-If / Reverse What-If 목표 역산 최적화"
```

- [ ] **Step 2: en/deck.yml에 동일 descs 추가 (영문 8개)**

```yaml
      data:
        no: "02"
        title: "Data Exploration"
        items: ["Data exploration", "WhatDataAI analysis", "Address XY cleansing", "AI exploratory charts", "AI text exploration", "Thematic map analysis", "AI insight report", "AI Target YX optimization"]
        descs:
          - "Descriptive stats and correlation heatmaps for loaded data"
          - "Auto-recommends usable AI algorithms (regression, discriminant, multi-class, time-series) and X/Y variables"
          - "Geocoding via Kakao API + trained address model: lat/long + standard admin region parsing"
          - "24 individual / 22 auto chart types: basic, distribution, relational, advanced"
          - "Word cloud analysis for tables and unstructured documents"
          - "Thematic maps: 5 admin boundary types, 7 grid/hexagon levels, VWorld & OpenStreetMap"
          - "Natural-language query on a knowledge graph → auto report with charts, maps, implications (no hallucination)"
          - "60-algorithm competition + What-If / Reverse What-If goal-seeking optimization"
```

- [ ] **Step 3: data 챕터 뷰 작성**

`app/views/pages/deck/_chapter_data.html.erb` 전체 교체:

```erb
<section id="data" class="deck-light deck-section">
  <div class="deck-wrap">
    <span class="deck-chapter-no" style="background:var(--blue);color:#fff;"><%= t("deck.chapters.data.no") %></span>
    <h2 class="deck-h2" style="color:#222;margin-top:12px;"><%= t("deck.chapters.data.title") %></h2>
    <div class="deck-grid deck-grid-4">
      <% items = t("deck.chapters.data.items"); descs = t("deck.chapters.data.descs") %>
      <% items.each_with_index do |item, i| %>
        <div class="deck-card">
          <div class="deck-card-num"><%= "%02d" % (i+1) %></div>
          <div class="deck-card-title"><%= item %></div>
          <div class="deck-card-desc"><%= descs[i] %></div>
        </div>
      <% end %>
    </div>
  </div>
</section>
```

- [ ] **Step 4: YAML 검증 + 렌더 검증**

Run:
```bash
ruby -ryaml -e "YAML.load_file('config/locales/ko/deck.yml'); YAML.load_file('config/locales/en/deck.yml'); puts 'OK'"
```
Expected: `OK`

서버 재시작 후:
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE 'WhatDataAI|주소 XY 정제|Target YX 최적화'
```
Expected: `3` 이상

- [ ] **Step 5: Commit**

```bash
git add app/views/pages/deck/_chapter_data.html.erb config/locales/ko/deck.yml config/locales/en/deck.yml
git commit -m "feat(deck): 02 데이터 탐색 챕터 (8종 메뉴)"
```

---

### Task 6: 03 AI 통계분석 챕터 (파이프라인 5단계 + 4종 분석 + Xim4Reporting)

**Files:**
- Modify: `app/views/pages/deck/_chapter_analysis.html.erb` (전체 교체)
- Modify: `config/locales/ko/deck.yml` + `en/deck.yml` (analysis 상세 추가)

- [ ] **Step 1: ko/deck.yml analysis 블록 확장**

`chapters: analysis:` 블록을 다음으로 교체:

```yaml
      analysis:
        no: "03"
        title: "AI 통계분석 솔루션"
        lead: "단순 통계 도구를 넘어 데이터 탐색부터 최적화 시뮬레이션·AI Q&A까지 원스톱. 60여 종 알고리즘 경쟁 + Reverse What-If로 비전문가도 업무 최적화."
        pipeline: ["변수 선정·파생데이터 생성", "변수 이해·XAI 변수 확정", "알고리즘 경쟁·실시간 검증", "예측·시뮬레이션 XY 최적화", "AI Q&A (Knowledge Graph & GraphRAG)"]
        methods: ["회귀분석 (32개 알고리즘)", "판별분석 (17개)", "다중분류분석 (17개)", "시계열분석 (61개)"]
        reporting: ["수시 성능 평가 분석", "수시 What-If Analysis", "수시 Reverse What-If Analysis"]
```

- [ ] **Step 2: en/deck.yml analysis 블록 확장**

```yaml
      analysis:
        no: "03"
        title: "AI Analytics Solution"
        lead: "Beyond a stats tool — one-stop from data exploration to optimization simulation and AI Q&A. 60+ competing algorithms plus Reverse What-If lets non-experts optimize."
        pipeline: ["Variable selection & derived features", "Variable understanding & XAI confirmation", "Algorithm competition & live validation", "Predict/simulate XY optimization", "AI Q&A (Knowledge Graph & GraphRAG)"]
        methods: ["Regression (32 algorithms)", "Discriminant (17)", "Multi-class (17)", "Time-series (61)"]
        reporting: ["On-demand performance evaluation", "On-demand What-If Analysis", "On-demand Reverse What-If Analysis"]
```

- [ ] **Step 3: analysis 챕터 뷰 작성**

`app/views/pages/deck/_chapter_analysis.html.erb` 전체 교체:

```erb
<section id="analysis" class="deck-dark deck-section">
  <div class="deck-wrap">
    <span class="deck-chapter-no"><%= t("deck.chapters.analysis.no") %></span>
    <h2 class="deck-h2" style="margin-top:12px;"><%= t("deck.chapters.analysis.title") %></h2>
    <p class="deck-lead"><%= t("deck.chapters.analysis.lead") %></p>

    <h3 style="color:#00C8C8;font-size:13px;margin-top:36px;font-family:ui-monospace,monospace;letter-spacing:1px;">// AI 분석 파이프라인 5단계</h3>
    <div class="deck-grid deck-grid-5" style="grid-template-columns:repeat(5,1fr);">
      <% t("deck.chapters.analysis.pipeline").each_with_index do |step, i| %>
        <div class="deck-card">
          <div class="deck-card-num" style="color:#00C8C8;font-size:18px;"><%= i+1 %></div>
          <div class="deck-card-title" style="font-size:13px;"><%= step %></div>
        </div>
      <% end %>
    </div>

    <h3 style="color:#00C8C8;font-size:13px;margin-top:36px;font-family:ui-monospace,monospace;letter-spacing:1px;">// 분석 종류와 방법</h3>
    <div class="deck-grid deck-grid-4">
      <% t("deck.chapters.analysis.methods").each do |m| %>
        <div class="deck-card"><div class="deck-card-title" style="font-size:13px;"><%= m %></div></div>
      <% end %>
    </div>

    <h3 style="color:#00C8C8;font-size:13px;margin-top:36px;font-family:ui-monospace,monospace;letter-spacing:1px;">// Xim4Reporting</h3>
    <div class="deck-grid deck-grid-3">
      <% t("deck.chapters.analysis.reporting").each do |r| %>
        <div class="deck-card"><div class="deck-card-title" style="font-size:13px;"><%= r %></div></div>
      <% end %>
    </div>
  </div>
</section>
```

- [ ] **Step 4: 그리드 5열 CSS 추가**

`app/views/pages/deck.html.erb`의 `<style>` 안 `.deck-grid-4` 줄 아래에 추가:

```css
  .deck-grid-5 { grid-template-columns:repeat(5,1fr); }
```
그리고 미디어쿼리 `@media (max-width:820px)`의 셀렉터에 `.deck-grid-5` 추가:
```css
  @media (max-width:820px){ .deck-grid-2,.deck-grid-3,.deck-grid-4,.deck-grid-5{grid-template-columns:1fr;} .deck-hero-title{font-size:32px;} .deck-nav-links{display:none;} }
```

- [ ] **Step 5: YAML + 렌더 검증**

```bash
ruby -ryaml -e "YAML.load_file('config/locales/ko/deck.yml'); YAML.load_file('config/locales/en/deck.yml'); puts 'OK'"
```
Expected: `OK`

서버 재시작 후:
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE 'Reverse What-If|Xim4Reporting|시계열분석'
```
Expected: `2` 이상

- [ ] **Step 6: Commit**

```bash
git add app/views/pages/deck/_chapter_analysis.html.erb app/views/pages/deck.html.erb config/locales/ko/deck.yml config/locales/en/deck.yml
git commit -m "feat(deck): 03 AI 통계분석 챕터 (파이프라인·4종·Xim4Reporting)"
```

---

### Task 7: 04 One-Stop 솔루션 챕터 (10종)

**Files:**
- Modify: `app/views/pages/deck/_chapter_solutions.html.erb` (전체 교체)

- [ ] **Step 1: solutions 챕터 뷰 작성 (items 이미 i18n에 있음)**

`app/views/pages/deck/_chapter_solutions.html.erb` 전체 교체:

```erb
<section id="solutions" class="deck-light deck-section">
  <div class="deck-wrap">
    <span class="deck-chapter-no" style="background:var(--blue);color:#fff;"><%= t("deck.chapters.solutions.no") %></span>
    <h2 class="deck-h2" style="color:#222;margin-top:12px;"><%= t("deck.chapters.solutions.title") %></h2>
    <p class="deck-lead" style="color:#3f3f3f;">데이터 로딩 → AI 현황분석 → What-If / Reverse What-If 최적화 → AI 종합 최적화 보고서. 도메인별 실전 의사결정 가이드.</p>
    <div class="deck-grid deck-grid-2">
      <% t("deck.chapters.solutions.items").each_with_index do |item, i| %>
        <div class="deck-card">
          <div class="deck-card-num"><%= "%02d" % (i+1) %></div>
          <div class="deck-card-title"><%= item %></div>
        </div>
      <% end %>
    </div>
  </div>
</section>
```

- [ ] **Step 2: 렌더 검증 (10개 솔루션 노출)**

Run:
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE 'Meeting 분석|예지보전|광고형 병의원'
```
Expected: `3`

- [ ] **Step 3: Commit**

```bash
git add app/views/pages/deck/_chapter_solutions.html.erb
git commit -m "feat(deck): 04 One-Stop 솔루션 챕터 (10종)"
```

---

### Task 8: 05 업무 활용 방안 챕터 + 최종 CTA

**Files:**
- Modify: `app/views/pages/deck/_chapter_usage.html.erb` (전체 교체)

- [ ] **Step 1: usage 챕터 + CTA 작성**

`app/views/pages/deck/_chapter_usage.html.erb` 전체 교체:

```erb
<section id="usage" class="deck-dark deck-section">
  <div class="deck-wrap">
    <span class="deck-chapter-no"><%= t("deck.chapters.usage.no") %></span>
    <h2 class="deck-h2" style="margin-top:12px;"><%= t("deck.chapters.usage.title") %></h2>
    <div class="deck-grid deck-grid-4">
      <% t("deck.chapters.usage.items").each_with_index do |item, i| %>
        <div class="deck-card">
          <div class="deck-card-num" style="color:#00C8C8;"><%= "%02d" % (i+1) %></div>
          <div class="deck-card-title" style="color:#fff;"><%= item %></div>
        </div>
      <% end %>
    </div>
  </div>
</section>

<%# 최종 CTA %>
<section class="deck-dark deck-section" style="text-align:center;padding-top:30px;border-top:1px solid rgba(255,255,255,0.08);">
  <div class="deck-wrap">
    <h2 class="deck-h2" style="margin:0 auto;max-width:680px;"><%= I18n.locale == :ko ? "비전문가도 5분 안에 의사결정을 끝냅니다." : "Even non-experts finish a decision in 5 minutes." %></h2>
    <div class="deck-hero-cta" style="justify-content:center;">
      <a href="<%= demo_path(locale: I18n.locale) %>" class="deck-btn-primary"><%= t("deck.hero.cta_demo") %></a>
      <a href="<%= contact_path(locale: I18n.locale) %>" class="deck-btn-ghost"><%= t("deck.hero.cta_contact") %></a>
    </div>
  </div>
</section>
```

- [ ] **Step 2: 렌더 검증**

Run:
```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE 'AX 활용성 강화|맞춤형 서비스 방안|5분 안에'
```
Expected: `3`

- [ ] **Step 3: Commit**

```bash
git add app/views/pages/deck/_chapter_usage.html.erb
git commit -m "feat(deck): 05 업무 활용 방안 챕터 + 최종 CTA"
```

---

### Task 9: 전체 검증 (앵커 네비 + 회귀 + 스크린샷)

**Files:** (검증 전용, 코드 변경 없음)

- [ ] **Step 1: 5챕터 전체 + 영문 렌더 검증**

```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -cE 'id="overview"|id="data"|id="analysis"|id="solutions"|id="usage"'
```
Expected: `5`

```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3022/en/deck
```
Expected: `200`

- [ ] **Step 2: 회귀 — 현 홈 무변경 확인**

```bash
curl -s http://127.0.0.1:3022/ko | grep -c 'id="architecture"'
```
Expected: `1` (이전 작업 그대로, deck 작업이 home에 영향 없음)

```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3022/ko
```
Expected: `200`

- [ ] **Step 3: Playwright 앵커 네비 + 스크린샷 검증**

`http://127.0.0.1:3022/ko/deck` 접속 → 상단 메뉴(데이터 탐색/솔루션 등) 클릭 → 해당 챕터로 스크롤 이동 확인 → Hero·각 챕터 스크린샷 캡처. (mcp__playwright 사용)

- [ ] **Step 4: XAISimTier 변형 노출 0건 확인**

```bash
curl -s http://127.0.0.1:3022/ko/deck | grep -c 'XAISimTier'
```
Expected: `0`

- [ ] **Step 5: 최종 Commit (검증 로그/스크린샷 정리)**

```bash
git add -A
git commit -m "test(deck): /deck 전체 검증 — 5챕터 렌더·앵커·회귀·스크린샷"
```

---

## Self-Review

**1. Spec coverage:**
- C안 완전 웹 재구성 → Task 3~8 (HTML/CSS 재구성) ✅
- PPTX 메뉴 = 사이트맵 → Task 2 (5챕터 items i18n) + Task 4~8 ✅
- 원페이지 + 앵커 네비 → Task 3 (nav 파셜, scroll-behavior, scroll-margin-top) ✅
- 하이브리드 톤 → Task 3 (deck-dark/deck-light CSS) ✅
- 현 홈 격리 → 모든 Task가 home 파일 미수정, Task 1·9 회귀 검증 ✅
- ko/en i18n → Task 2,5,6 ✅
- 성공 기준 5개 → Task 9에서 전부 검증 ✅

**2. Placeholder scan:** 모든 step에 실제 코드/명령/기대출력 포함. 빈 파셜은 Task 3에서 의도적 임시 생성 후 Task 4~8에서 실제 콘텐츠로 교체(명시). placeholder 없음. ✅

**3. Type consistency:**
- i18n 키 일관: `deck.chapters.<key>.items/descs/pipeline/methods/reporting` — Task 2 정의, Task 4~8 사용 일치 ✅
- 파셜명 일관: `pages/deck/chapter_*` — Task 3 render, Task 4~8 파일명 일치 ✅
- CSS 클래스: `.deck-grid-5`는 Task 6 Step 4에서 추가 후 사용 (정의 후 사용) ✅
- 앵커 id: nav href(#overview 등) ↔ section id 일치 ✅ (단 overview는 Hero section에 id, Task 4에서 Hero에 id="overview" 부여 — Task 3 빈 파셜의 id와 중복되므로 Task 4에서 빈 파셜 전체 교체 시 해소)

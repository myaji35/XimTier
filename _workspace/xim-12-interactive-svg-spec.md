# XIM-12 — 해자 삼각형 + 5단계 워크플로우 인터랙티브 SVG 사양

**Issue:** XIM-12 (DESIGN)
**Source:** PRD §8.2 / PitchDeck Slide 3 (5단계 워크플로우) / Slide 6 (해자 삼각형)
**기존 정적 컴포넌트:**
- `app/components/moat_triangle_component.html.erb` (SVG, 정적)
- `app/components/workflow_steps_component.html.erb` (5단계 카드 그리드, 정적)
**랜딩 통합 지점:** `app/views/pages/home.html.erb` §05 Solution / §06 Moat

---

## 0. 목표 & 비-목표

| 구분 | 내용 |
|---|---|
| **목표** | (1) 정적 SVG/카드를 **호버·스크롤 인터랙션**으로 격상해 "증명되는 답" 메시지를 시각적으로 입증한다. (2) 모바일/접근성 fallback 보장. (3) 단일 Stimulus 컨트롤러 인터페이스로 통일 — 추후 i18n/콘텐츠 변경에 컴포넌트 수정 없이 대응. |
| **비-목표** | 차트 라이브러리(D3/echarts) 도입 금지. WebGL/Lottie 금지. 외부 의존 0 — `@hotwired/stimulus`만 사용. |

### 성공 기준 (Goal-Driven)
1. 데스크톱: 해자 삼각형 정점 호버 시 200ms 이내 highlight + 우측 카드와 양방향 동기화.
2. 데스크톱: 5단계 워크플로우 — 카드 호버/포커스 시 해당 단계만 emphasis, ★ Reverse What-If 단계는 무조건 시각적 weight 1.5×.
3. 스크롤 진입 시 두 컴포넌트 모두 1회만 entrance reveal (IntersectionObserver, 50% threshold).
4. 모바일 (<980px): 호버 비활성, 탭으로 동작. 인터랙션 없어도 콘텐츠 100% 전달.
5. Lighthouse Accessibility ≥ 95, `prefers-reduced-motion: reduce` 시 모든 motion 0ms.

---

## 1. 해자 삼각형 (Moat Triangle) — 인터랙티브 SVG 사양

### 1.1 구조 (좌: SVG / 우: 텍스트 패널 — 기존 그리드 유지)

```
viewBox: 0 0 460 400
정점 A (top)         x=230 y=70   🔒 Data Sovereignty
정점 B (bottom-left) x=70  y=320  🔄 Reverse What-If
정점 C (bottom-right)x=390 y=320  ⚖ Regulated AI
중앙 Disc           x=230 y=200  XST (gradient)
```

### 1.2 인터랙션 매트릭스

| 트리거 | 대상 | 효과 | 지속/타이밍 |
|---|---|---|---|
| **Vertex hover/focus** (데스크톱) | 해당 vertex `<g>` | (a) `circle` r 18→22, (b) text bold weight 600→700, (c) glow filter `drop-shadow(0 0 12px rgba(37,99,235,.35))` 추가 | enter 180ms · ease-out, leave 240ms |
| **Vertex hover/focus** | 우측 카드 (동일 인덱스) | `data-active="true"` → `box-shadow: 0 12px 28px -12px rgba(37,99,235,.35)`, border 색 → `#2563EB` | 180ms |
| **Vertex hover/focus** | 다른 두 vertex + 카드 | `opacity: 0.45` (de-emphasis) | 180ms |
| **Vertex hover/focus** | 점선 connecting lines | hover된 정점에 연결된 2개 line은 `opacity: 1`, `stroke-dasharray: 6 4` (dash 확대), 나머지 1개 `opacity: 0.2` | 220ms |
| **Card hover/focus** (우측) | 동일 인덱스 vertex | 위 vertex hover 효과를 동일하게 발사 (양방향) | 180ms |
| **Center disc hover** | XST disc | scale 1 → 1.06, glow 강화 | 200ms · cubic-bezier(0.4,0,0.2,1) |
| **Scroll into view** (≥50%) | 전체 SVG | (a) 점선 3개 stroke-dashoffset 200→0 (draw-in, 0.9s), (b) 정점 3개 0.3s씩 stagger fade+pop, (c) 중앙 disc 가장 마지막 0.5s scale-in | 1회만 (`is-revealed` 클래스 부착 후 unobserve) |
| **모바일 tap** | vertex | 위 vertex hover 효과를 toggle. 다음 vertex tap 시 이전 해제 | 즉시 |
| **prefers-reduced-motion: reduce** | 전체 | 모든 transition `duration: 0ms`, draw-in 생략, 색·border 변경만 유지 | — |

### 1.3 키보드 접근성

- 각 vertex `<g>` → `tabindex="0"`, `role="button"`, `aria-label="해자 차원: 데이터 주권"` 등.
- `Enter` / `Space` → tap 동작과 동일한 toggle.
- 카드 컨테이너 `<article>` 도 동일하게 `tabindex="0"`.
- 화살표 키 ←/→ → 인접 vertex 로 포커스 이동 (sovereignty → reverse → regulated → sovereignty 순환).
- focus visible: `outline: 2px solid #2563EB; outline-offset: 4px`.

### 1.4 Stimulus controller 인터페이스 — `moat_triangle_controller.js`

```js
// app/javascript/controllers/moat_triangle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "svg",           // <svg> 루트
    "vertex",        // <g> × 3, data-key="sovereignty|reverse|regulated"
    "card",          // 우측 <article> × 3, data-key=동일
    "line",          // 점선 <line> × 3, data-pair="A-B|A-C|B-C"
    "disc"           // 중앙 disc <g>
  ]

  static values = {
    activeKey: { type: String, default: "" },          // 현재 강조된 차원
    revealed:  { type: Boolean, default: false },       // 스크롤 reveal 1회 가드
    reduceMotion: { type: Boolean, default: false }     // prefers-reduced-motion 결과
  }

  static classes = ["active", "muted", "revealed"]

  connect() { /* IntersectionObserver 부착, reduce-motion 감지 */ }
  disconnect() { /* observer/listener 해제 */ }

  // Actions (data-action에서 호출)
  highlight(event)  { /* event.currentTarget.dataset.key 로 active 설정 */ }
  release(event)    { /* mouseleave/blur 시 active 해제 */ }
  toggle(event)     { /* 모바일 tap, keyboard Enter/Space */ }
  navigate(event)   { /* ←/→ 키 처리, prevent default + 인접 vertex focus */ }

  // 내부
  _applyActive(key) { /* vertex/card/line opacity & 스타일 일괄 갱신 */ }
  _reveal()         { /* IntersectionObserver 콜백, draw-in 트리거 후 unobserve */ }
}
```

### 1.5 ERB 마크업 변경 사항 (기존 `moat_triangle_component.html.erb`)

```erb
<%# Wrapper %>
<div data-controller="moat-triangle"
     data-moat-triangle-active-key-value=""
     class="grid md:grid-cols-2 items-center" style="gap:60px;">

  <%# SVG %>
  <svg data-moat-triangle-target="svg" ...>
    <%# line 3개에 target/data-pair 부여 %>
    <line data-moat-triangle-target="line" data-pair="sovereignty-reverse" .../>
    ...
    <%# vertex 3개를 <g> 로 묶고 target/key/접근성 속성 부여 %>
    <g data-moat-triangle-target="vertex"
       data-key="sovereignty"
       tabindex="0" role="button"
       aria-label="<%= t('moat.triangle.points.sovereignty.aria') %>"
       data-action="mouseenter->moat-triangle#highlight
                    mouseleave->moat-triangle#release
                    focus->moat-triangle#highlight
                    blur->moat-triangle#release
                    click->moat-triangle#toggle
                    keydown.enter->moat-triangle#toggle
                    keydown.space->moat-triangle#toggle
                    keydown.right->moat-triangle#navigate
                    keydown.left->moat-triangle#navigate">
      <rect .../>
      <text .../>
    </g>
    ...
    <g data-moat-triangle-target="disc">…</g>
  </svg>

  <%# 우측 카드: 동일 data-key 부여 %>
  <div class="space-y-5">
    <% [sovereignty, regulated, reverse].each do |point| %>
      <article data-moat-triangle-target="card"
               data-key="<%= point[:key] %>"
               tabindex="0"
               class="card" ...>...</article>
    <% end %>
  </div>
</div>
```

> **데이터 계약 변경:** `MoatTriangleComponent.new(...)` 호출부에서 각 point hash에 `key:` (`:sovereignty | :reverse | :regulated`) 추가. i18n 측에는 `points.<key>.aria` 키 추가 (스크린리더용).

### 1.6 CSS 토큰 (brand-dna.json 기반)

```css
/* 컴포넌트 스코프 — 인라인 또는 application.css */
[data-controller="moat-triangle"] [data-moat-triangle-target="vertex"] {
  cursor: pointer;
  transition: opacity 180ms cubic-bezier(0.4,0,0.2,1);
}
[data-controller="moat-triangle"][data-moat-triangle-active-key-value=""]
  [data-moat-triangle-target="vertex"] { opacity: 1; }
[data-controller="moat-triangle"]:not([data-moat-triangle-active-key-value=""])
  [data-moat-triangle-target="vertex"]:not([data-active]) { opacity: 0.45; }

[data-moat-triangle-target="vertex"][data-active] rect {
  filter: drop-shadow(0 0 12px rgba(37,99,235,0.35));
}
[data-moat-triangle-target="card"][data-active] {
  border-color: #2563EB;
  box-shadow: 0 12px 28px -12px rgba(37,99,235,0.35);
}

/* 스크롤 reveal */
[data-moat-triangle-target="line"] {
  stroke-dasharray: 4 5;
  stroke-dashoffset: 200;
  transition: stroke-dashoffset 900ms ease-out;
}
[data-moat-triangle-active-revealed-value="true"]
  [data-moat-triangle-target="line"] { stroke-dashoffset: 0; }

@media (prefers-reduced-motion: reduce) {
  [data-controller="moat-triangle"] * { transition-duration: 0ms !important; }
  [data-moat-triangle-target="line"] { stroke-dashoffset: 0 !important; }
}
```

---

## 2. 5단계 워크플로우 (Workflow Steps) — 인터랙티브 사양

### 2.1 데이터 계약 (i18n `workflow.steps`)

```yaml
workflow:
  steps:
    - { key: explore,  title: "데이터 탐색",  sub: "WhatDataAI",        desc: "..." }
    - { key: stats,    title: "통계 분석",    sub: "Regression / SHAP", desc: "..." }
    - { key: reverse,  title: "Reverse What-If", sub: "★ 핵심",         desc: "..." }
    - { key: report,   title: "자동 보고서",  sub: "Auto Report",       desc: "..." }
    - { key: qa,       title: "AI Q&A",       sub: "Chat",              desc: "..." }
```

> 기존 컴포넌트는 `★` 포함 여부로 core 단계를 판정 — **유지**. 추가로 `key` 필드를 받아 controller가 식별한다.

### 2.2 인터랙션 매트릭스

| 트리거 | 대상 | 효과 | 타이밍 |
|---|---|---|---|
| **Card hover/focus** | 해당 카드 | `transform: translateY(-4px)`, `box-shadow: 0 16px 40px -16px rgba(11,19,45,0.18)`, sub 텍스트 색 → `#00C8C8` | 220ms · ease-out |
| **Card hover/focus** | 다른 카드 | `opacity: 0.6` | 180ms |
| **Card hover/focus** | 인접 화살표 (`→`) | 화살표 색 `#94a3b8` → `#2563EB`, `transform: translateX(4px)` | 180ms |
| **★ Reverse What-If 카드** | — | 기본 상태에서 항상 gradient border + soft pulse(2.4s loop, opacity 0.85↔1.0 그림자) | 무한 루프 (reduced-motion 시 정지) |
| **Scroll into view** (≥40%) | 5개 카드 | 좌→우 stagger fade-in (각 80ms 간격, translateY 12px → 0) | 1회 |
| **Stage progress (선택 옵션)** | — | 페이지 스크롤 진행률에 따라 STEP 01~05 가 순차 활성. **MVP에서는 비활성** (Phase 2) | — |
| **모바일 tap** | 카드 | hover 효과를 toggle. desc 영역이 collapsed → expanded 전환 (모바일에서는 desc 기본 hidden, tap 시 펼침) | 200ms |

### 2.3 키보드 접근성

- 각 카드 `<article tabindex="0" role="group" aria-label="단계 1: 데이터 탐색">`.
- ←/→ 키로 카드 순회. Home/End 로 처음/끝.
- focus-visible: `outline: 2px solid #2563EB; outline-offset: 3px; border-radius: 14px`.

### 2.4 Stimulus controller 인터페이스 — `workflow_steps_controller.js`

```js
// app/javascript/controllers/workflow_steps_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets  = ["card", "arrow"]
  static values   = {
    activeKey:   { type: String,  default: "" },
    revealed:    { type: Boolean, default: false },
    reduceMotion:{ type: Boolean, default: false }
  }
  static classes  = ["active", "muted", "revealed"]

  connect() { /* IntersectionObserver, prefers-reduced-motion */ }
  disconnect() { /* cleanup */ }

  highlight(event) { /* event.currentTarget.dataset.key 로 active 설정 */ }
  release(event)   { /* mouseleave/blur */ }
  toggle(event)    { /* 모바일 tap → desc expand toggle */ }
  navigate(event)  { /* ←/→/Home/End */ }

  _applyActive(key) { /* card/arrow 일괄 갱신 */ }
  _reveal()         { /* stagger fade-in */ }
}
```

### 2.5 ERB 변경

```erb
<div data-controller="workflow-steps"
     data-workflow-steps-active-key-value=""
     class="grid grid-cols-1 md:grid-cols-5" style="gap:16px;">
  <% steps.each_with_index do |step, i| %>
    <% key = step[:key] || step["key"] %>
    <article data-workflow-steps-target="card"
             data-key="<%= key %>"
             data-step-index="<%= i %>"
             tabindex="0" role="group"
             aria-label="단계 <%= i+1 %>: <%= title %>"
             data-action="mouseenter->workflow-steps#highlight
                          mouseleave->workflow-steps#release
                          focus->workflow-steps#highlight
                          blur->workflow-steps#release
                          click->workflow-steps#toggle
                          keydown.enter->workflow-steps#toggle
                          keydown.right->workflow-steps#navigate
                          keydown.left->workflow-steps#navigate
                          keydown.home->workflow-steps#navigate
                          keydown.end->workflow-steps#navigate"
             class="relative rounded-[14px] p-5 transition" ...>
      ... (기존 마크업 유지)
      <% unless i == steps.size - 1 %>
        <div data-workflow-steps-target="arrow" data-pair-from="<%= key %>" ...>
          <svg>…</svg>
        </div>
      <% end %>
    </article>
  <% end %>
</div>
```

### 2.6 ★ Reverse 카드 pulse CSS

```css
@keyframes xim-pulse-core {
  0%, 100% { box-shadow: 0 8px 32px -12px rgba(37,99,235,0.45); }
  50%      { box-shadow: 0 12px 40px -10px rgba(37,99,235,0.65); }
}
[data-workflow-steps-target="card"][data-core="true"] {
  animation: xim-pulse-core 2.4s ease-in-out infinite;
}
@media (prefers-reduced-motion: reduce) {
  [data-workflow-steps-target="card"][data-core="true"] { animation: none; }
}
```

> ★ 판정은 ERB 단에서 `is_core` 값을 `data-core="true"` 로 emit.

---

## 3. 공통 — Reveal Observer 패턴

두 컨트롤러 모두 동일한 IntersectionObserver 패턴을 사용한다 (중복 제거를 위해 추후 `lib/use_reveal.js` 헬퍼로 추출 가능, MVP 단계에서는 각자 인라인):

```js
_setupReveal() {
  if (this.revealedValue) return
  this._io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting && e.intersectionRatio >= this._threshold) {
        this.revealedValue = true
        this.element.dataset.revealed = "true"
        this._io.disconnect()
      }
    })
  }, { threshold: [0, 0.4, 0.5, 1] })
  this._io.observe(this.element)
}
```

`threshold`: 워크플로우 0.4, 해자 0.5.

---

## 4. 반응형 / 디바이스 매트릭스

| 브레이크포인트 | 해자 삼각형 | 5단계 워크플로우 |
|---|---|---|
| **≥980px (desktop)** | 좌측 SVG (480px max) + 우측 카드 2:1 비율. 호버 인터랙션 풀로 동작. | 5열 가로 그리드. 카드 사이 화살표 표시. hover translateY. |
| **<980px (tablet/mobile)** | SVG 폭 100% (max 360px). 우측 카드 SVG 아래로 스택. **호버 비활성, tap 활성**. | 1열 세로 스택. 화살표 hidden. desc 기본 표시 (collapse 없음). pulse 유지(reduced-motion 외). |
| **prefers-reduced-motion** | 모든 transition 0ms. draw-in/stagger 생략. 색·border 변경만 유지. pulse 정지. | 동일. |

---

## 5. 분석 / 텔레메트리 (선택)

성과 측정용 PostHog/GA 이벤트 hook 지점 (구현은 별도 이슈):

| 이벤트 | 트리거 | payload |
|---|---|---|
| `moat_vertex_engaged` | vertex hover ≥ 600ms 또는 tap | `{ key, source: "hover\|tap\|kbd" }` |
| `workflow_step_engaged` | 카드 hover ≥ 600ms 또는 tap | `{ step_index, key }` |
| `moat_revealed` | reveal 발생 | `{ duration_ms_from_load }` |

---

## 6. 검증 체크리스트 (수용 기준)

### 코드/구현
- [ ] `moat_triangle_controller.js` / `workflow_steps_controller.js` 두 파일 신규 추가
- [ ] `controllers/index.js` 자동 등록 (Stimulus default)
- [ ] 컴포넌트 ERB에 data-attribute 추가, 호출부 hash에 `key` 필드 추가
- [ ] i18n 키 `moat.triangle.points.<key>.aria` 3개 추가 (ko/en)
- [ ] application.css 또는 컴포넌트 인라인 스타일에 위 §1.6 / §2.6 CSS 추가

### UX/접근성
- [ ] axe-core 0건 violation (focus order, aria-label)
- [ ] 키보드만으로 모든 vertex/card 도달 + 활성화 가능
- [ ] `prefers-reduced-motion: reduce` 시 motion 0ms
- [ ] 스크린리더 (VoiceOver) — vertex 포커스 시 "버튼, 해자 차원: 데이터 주권" 식 안내
- [ ] 모바일 (iOS Safari, Android Chrome) — tap 토글 정상

### 성능
- [ ] 두 컴포넌트 합쳐서 추가 JS < 4KB gzip
- [ ] 60fps hover (DevTools Performance, scripting < 4ms/frame)
- [ ] LCP/CLS 영향 없음 (스크롤 reveal은 transform/opacity만)

### Playwright 캐릭터 저니 (CLAUDE.md 룰)
- [ ] J1: 비전문가 방문자 → `/` 진입 → 해자 정점 호버 → 우측 카드 동기화 스크린샷
- [ ] J2: 키보드 사용자 → Tab으로 vertex 도달 → Enter → 카드 활성 확인
- [ ] J3: 모바일 사용자 → 워크플로우 ★ 카드 tap → desc expand 확인

---

## 7. 다음 단계 (이 사양 승인 후)

| 후속 이슈 | 타입 | 담당 |
|---|---|---|
| `XIM-12.1` controller 2종 구현 | GENERATE_CODE | agent-harness |
| `XIM-12.2` ERB/i18n 마이그레이션 + key 필드 추가 | GENERATE_CODE | agent-harness |
| `XIM-12.3` Playwright 저니 검증 (J1/J2/J3) | SCENARIO_PLAY | scenario-player |
| `XIM-12.4` (선택) PostHog 이벤트 hook | GENERATE_CODE | agent-harness |

---

**Author:** UXDesigner agent (80e4ef7d-5326-4ea7-b317-47fe423ecd73)
**Date:** 2026-05-14
**Status:** READY FOR REVIEW (구현 시작 전 design-critic + 대표님 1차 검토 권장)

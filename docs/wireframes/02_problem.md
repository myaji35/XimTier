# W2 — `/problem` 문제 페이지 (한/영 미러)

## 1. 목표 & 청자

| 청자 | 떠날 때 머릿속 |
|---|---|
| 김 상무 | "우리 사내 사례가 여기 그대로 있다" → /solution 다음 |
| 박 사무관 | "공공 데이터 외부 반출 불가 = 우리 얘기" → /use-cases |

**핵심 전환**: 다음 페이지 `/solution`. 부차적으로 `/contact`.

---

## 2. 모바일 와이어 (360px)

```
┌─────────────────────────────────────────┐
│ ☰ [X] XimTier            [KO|EN] [Demo→]│
├─────────────────────────────────────────┤
│  (Light Hero, eyebrow + h1 + lead)       │
│                                          │
│  EYEBROW: 문제 / The Problem             │
│  H1: "LLM은 왜 의사결정을 못 푸는가"      │
│  LEAD: "환각·보안·추론 — 세 가지 한계가   │
│         기업의 의사결정 자동화를 막는다." │
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  PROBLEM 1 — 환각                        │
│                                          │
│  ┌─ left col (mobile = stacked) ────────┐│
│  │  [icon-alert, 56px, teal]            ││
│  │  H2: "그럴듯한 숫자가 틀린 숫자"      ││
│  │  PARA (3-4줄)                         ││
│  │   "LLM이 '매출 17억'이라 답해도        ││
│  │   근거 추적이 불가능. 회계 감사,       ││
│  │   규제 보고에 그대로 못 씀."           ││
│  └──────────────────────────────────────┘│
│  ┌─ right col (mobile = below) ─────────┐│
│  │  [실제 사례 박스, code-block 스타일]  ││
│  │  Q: "Q3 우리 공장 가동률은?"          ││
│  │  A (LLM): "약 78%로 추정됩니다..."    ││
│  │  ⚠ 출처 추적 불가, 숫자 검증 불가      ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← light section
│  PROBLEM 2 — 보안                        │
│                                          │
│  [icon-lock] H2: "기업 데이터는           │
│              외부 LLM에 못 보냄"          │
│  PARA: "ChatGPT 입력 금지 정책이          │
│         삼성·LG 등 대기업부터 정부까지    │
│         확산. 그러나 분석 수요는 그대로." │
│                                          │
│  ┌─ Quote card ─────────────────────────┐│
│  │ "사내 데이터 외부 반출 시             ││
│  │  영업비밀보호법 위반 — 최대 5억 벌금"  ││
│  │ — 산업기술보호법 §9                   ││
│  └──────────────────────────────────────┘│
│                                          │
├─────────────────────────────────────────┤  ← dark section
│  PROBLEM 3 — 추론                        │
│                                          │
│  [icon-split] H2: "원인-결과를            │
│               따라가지 못함"              │
│  PARA: "LLM은 패턴 매칭. '왜 매출이       │
│         떨어졌나'를 묻는 순간 답이 갈림.  │
│         의사결정은 인과 추론이 필수."     │
│                                          │
│  [시각 자료: LLM vs XAI Reasoning 비교]  │
│  ┌──────────────┬─────────────────────┐ │
│  │ LLM          │ XimTier             │ │
│  │ 패턴 매칭     │ 인과 그래프          │ │
│  │ 단일 답변     │ Reverse What-If     │ │
│  │ 근거 X        │ XAI 추적            │ │
│  └──────────────┴─────────────────────┘ │
│                                          │
├─────────────────────────────────────────┤  ← tinted section
│  Bridge: "그럼, 어떻게 풀까?"             │
│                                          │
│  H2: "다음 — 해결책"                      │
│  [ /solution 으로 이동 → ]                │
│  (보조) [ 데모 신청하기 ]                  │
├─────────────────────────────────────────┤
│  FOOTER                                  │
└─────────────────────────────────────────┘
```

---

## 3. 데스크톱 와이어 (≥980px)

- 각 PROBLEM 섹션은 **2 컬럼 (60/40)** 좌측 텍스트, 우측 사례 박스
- Problem 1·3 = 다크 / Problem 2 = 라이트 (라이트-다크 교차)
- 비교 테이블(Problem 3 하단)은 데스크톱에서 2컬럼 그리드, 모바일에서는 가로 스크롤 가능 카드

---

## 4. i18n 키 슬롯

```yaml
problem:
  hero: { eyebrow: "문제", h1: "LLM은 왜 의사결정을 못 푸는가", lead: "..." }
  hallucination:
    h2: "그럴듯한 숫자가 틀린 숫자"
    body: "..."
    example_q: "Q3 우리 공장 가동률은?"
    example_a: "약 78%로 추정됩니다..."
    warning: "출처 추적 불가, 숫자 검증 불가"
  security:
    h2: "기업 데이터는 외부 LLM에 못 보냄"
    body: "..."
    quote: "사내 데이터 외부 반출 시 영업비밀보호법 위반 — 최대 5억 벌금"
    quote_source: "산업기술보호법 §9"
  reasoning:
    h2: "원인-결과를 따라가지 못함"
    body: "..."
    compare_table:
      header: ["LLM", "XimTier"]
      rows:
        - ["패턴 매칭", "인과 그래프"]
        - ["단일 답변", "Reverse What-If"]
        - ["근거 X", "XAI 추적"]
  bridge: { h2: "다음 — 해결책", cta: "/solution 으로 이동" }
```

---

## 5. 인터랙션

- 각 Problem 섹션 진입 시 아이콘 → 옅은 펄스 1회 (`prefers-reduced-motion` 존중)
- Problem 3 비교 테이블은 모바일에서 **swipe gesture** 가능 (carousel) — Stimulus `swipe_controller`
- Bridge CTA hover: 화살표 → 우측 8px 슬라이드

---

## 6. LCP 예산

- LCP 후보: Hero `<h1>` (텍스트)
- 아이콘은 모두 inline SVG ≤ 1KB
- 다크/라이트 교차 = CSS variable 전환만, 이미지 X
- Above-fold ~32KB (W1보다 작음, 마진 충분)

---

## 7. 분석 이벤트

| 이벤트 | 트리거 |
|---|---|
| `problem_section_view` | 각 Problem 50% viewport. props: `{ problem: "hallucination"|"security"|"reasoning" }` |
| `compare_table_swipe` | Problem 3 테이블 swipe. props: `{ direction }` |
| `bridge_cta_click` | "/solution 으로 이동" 클릭 |

---

## 8. a11y

- 각 `Problem N` 섹션은 `<section aria-labelledby="problem-N-h2">`
- 비교 테이블은 진짜 `<table>` + `<th scope="col">` (스크롤 캐러셀화 시 table semantic 유지)
- Quote 박스는 `<blockquote>` + `<cite>`
- 다크-라이트 교차 영역에서 텍스트 대비 검증 (WCAG AA: 라이트 본문 #1f2937 / 다크 본문 #e6e8f0)

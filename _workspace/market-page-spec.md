# XimTier 시장 가치($81B) — 홈페이지 반영 기획서

> 작성: 2026-05-13 / CTO
> 베이스: `~/Downloads/XimTier_TAM_81B_근거_260513.pdf` (Pre-Seed Investor Pack 부록)
> 목표: 보고서의 IR 화법을 **방문자도 30초에 이해**할 수 있는 형태로 홈페이지에 자연스럽게 노출

---

## 0. 전제 — 왜 홈페이지에 시장 정보를 넣는가

| 청자 | 현재 노출 위치 | 갭 |
|---|---|---|
| **VC / Investor** | `/company/investors` (IR PDF 다운로드만) | "왜 $81B인가" 즉답 없음 — 메일로 PDF 받아야만 알 수 있음 |
| **기업 의사결정자** | `/use-cases`, `/cases/*` | 시장 규모 자체에 관심 적음 — 그러나 "큰 시장의 표준"이라는 신호는 신뢰감 ↑ |
| **개발자 / 파트너** | `/platform-api` | MCP 생태계가 얼마나 큰지 모름 |
| **언론 / 분석가** | 없음 | 인용 가능한 정량 데이터 부재 |

→ **결론**: 홈페이지에 시장 가치를 노출하면 모든 청자에게 *"이건 진짜 큰 일을 노리는 회사다"* 신호. 그러나 **피치덱처럼 숫자 폭격**이 아니라 **쉬운 설명 + 인터랙티브** 형태로.

---

## 1. 정보 구조 (IA) — 3곳에 분산 노출

### A. **홈 페이지 새 섹션** — 가벼운 1줄 노출
- 기존 "시장 지표" 카드 5개 (Hero 아래) → **확장**
- 4 카드 (TAM / SAM / SOM / CAGR) + 1줄 설명
- 클릭 → `/company/market` (신규 페이지)로 이동

### B. **신규 페이지 `/company/market`** — 깊이 있는 설명
- 보고서 9 섹션을 5섹션으로 압축한 페이지
- 인터랙티브 시나리오 토글 (Bull / Base / Worst)
- 합산 모델 시각화 + 출처 8개 카드
- IR PDF 다운로드 CTA

### C. **Investors 페이지 보강** — IR PDF 다운로드와 연결
- 기존 다운로드 폼 위에 "30초 요약" 카드 노출
- "더 깊이 보기 → /company/market" 링크

---

## 2. 신규 페이지 `/company/market` 상세 설계

### 2.1 페이지 URL + 라우트
```ruby
# config/routes.rb
get "/company/market", to: "pages#market", as: :market
```

### 2.2 컨트롤러
```ruby
# app/controllers/pages_controller.rb
def market; end
```

### 2.3 페이지 IA (7 섹션, 라이트/다크 교차)

#### 섹션 1 (다크 Hero) — "왜 $81B인가" 한 줄
```
EYEBROW: 시장 가치 / Market
H1: $81B 시장 — 합산 모델로 검증
LEAD: "이 숫자는 단일 출처가 아닙니다. 인접 3시장의 비중복 합산입니다."

KPI 4카드: $81B (Bull) / $50.1B (Base) / $36.3B (Conservative) / +28.5% CAGR
하단 CTA: "근거 리서치 PDF 받기" → 다운로드 폼
```

#### 섹션 2 (라이트) — 시나리오 토글 (Stimulus 인터랙티브)
```
"투자자 성향에 따라 3가지 시나리오를 준비했습니다"

[Bull] [Base] [Worst]  ← 탭 클릭으로 전환

선택된 시나리오 카드:
- 큰 숫자 ($81B / $50.1B / $36.3B)
- 산출 공식 (Formula box)
- 한 줄 설명
- "이 시장의 0.46%만 점유해도 ARR ₩30억"
```

#### 섹션 3 (라이트) — 합산 모델 시각화
```
"시장 합산 모델 (Sum of Adjacent Markets)"

3개 원이 겹치는 벤다이어그램 (SVG):
- DI ($43B) — 큰 원
- XAI ($21B) — 중간 원
- Prescriptive ($17B) — 작은 원
- 중복분 $14B 강조

"중복은 빼서 부풀리지 않았습니다" 캡션
```

#### 섹션 4 (다크) — "왜 지금인가" 3개 트렌드
```
기존 Why Now 섹션의 3카드 재활용 + 정량 출처 추가
- 30~50% Gen AI 실패 (Gartner 2024-2025)
- €17B EU AI Act 컴플라이언스 시장 (2030)
- 85% 기업 LLM 금지율 (Cisco AI Survey)
```

#### 섹션 5 (라이트) — TAM/SAM/SOM 깔때기
```
"우리가 닿을 수 있는 시장은?"

3개 동심원 (SVG) 또는 깔때기:
TAM $81B → SAM $18B → SOM $500M

각 단계 설명:
- TAM: 글로벌 잠재 시장
- SAM: 우리가 닿을 수 있는 비즈니스 분석 SaaS
- SOM: Y3까지 한국·동남아 SME 대상

"ARR ₩30억 = SOM의 0.46%" 강조 카드
```

#### 섹션 6 (라이트) — 1차 출처 8개
```
"이 모든 숫자의 출처"

8개 카드 (로고 + 인용 + 수치):
M&M / Grand View / Grand View XAI / Grand View Prescriptive /
Research & Markets / Gartner / EU Commission / Statista
```

#### 섹션 7 (다크 CTA) — IR Pack 다운로드
```
"VC 미팅에 가져가실 분?"

"$81B 근거 리서치 PDF (5페이지) 받기" → /company/investors 폼
"5분 데모로 직접 보기" → /demo
```

---

## 3. 컴포넌트 설계

### 3.1 신규 ViewComponent (3개)

| 컴포넌트 | 역할 | 파일 |
|---|---|---|
| `MarketScenarioToggleComponent` | Bull/Base/Worst 탭 + Stimulus | `app/components/market_scenario_toggle_component.{rb,html.erb}` + `app/javascript/controllers/market_scenario_controller.js` |
| `MarketVennComponent` | 3원 벤다이어그램 SVG (DI/XAI/Prescriptive) | `app/components/market_venn_component.*` |
| `MarketFunnelComponent` | TAM→SAM→SOM 동심원/깔때기 SVG | `app/components/market_funnel_component.*` |

### 3.2 재사용 (기존)
- `SectionComponent` — 섹션 1, 4, 5, 7
- `StatIndicatorComponent` — KPI 카드 4개
- `CtaComponent` — Section 1, 7 버튼

---

## 4. i18n YAML 설계 (`config/locales/{ko,en}/market_page.yml`)

### 4.1 한글 카피 초안

```yaml
ko:
  market_page:
    eyebrow: 시장 가치
    h1: $81B 시장 — 합산 모델로 검증
    lead: 이 숫자는 단일 출처가 아닙니다. 인접 3시장의 비중복 합산입니다.

    kpis:
      bull:   { value: "$81B",    label: "Bull TAM",      sub: "DI + XAI + Prescriptive 비중복 합산" }
      base:   { value: "$50.1B",  label: "Base TAM",      sub: "MarketsandMarkets DI 단독" }
      worst:  { value: "$36.3B",  label: "Worst TAM",     sub: "Grand View DI 단독" }
      cagr:   { value: "+28.5%",  label: "CAGR",          sub: "2025-2030 가중 평균" }

    scenarios:
      title: "투자자 성향에 따라 3가지 시나리오를 준비했습니다"
      bull:
        label: 공격적 (Bull)
        value: "$81B"
        formula: "DI($43B) + XAI($21B) + Prescriptive 비중복($17B)"
        body: "XimTier가 닿을 수 있는 인접 3시장 합산. 중복분 $14B는 차감."
      base:
        label: 표준 (Base)
        value: "$50.1B"
        formula: "MarketsandMarkets Decision Intelligence 단독"
        body: "권위 있는 단일 출처. VC가 가장 신뢰하는 default 인용값."
      worst:
        label: 보수적 (Worst)
        value: "$36.3B"
        formula: "Grand View Research Decision Intelligence 단독"
        body: "가장 짠 단일 출처. 이 시장 0.1%만 점유해도 ARR ₩500억."

    sum_model:
      title: 시장 합산 모델
      lead: 단순 더하기가 아닙니다. 시장 간 중복을 빼서 부풀리지 않았습니다.
      circles:
        di:           { value: "$43B", label: "Decision Intelligence" }
        xai:          { value: "$21B", label: "Explainable AI (XAI)" }
        prescriptive: { value: "$17B", label: "Prescriptive Analytics (비중복)" }
      caption: "중복분 $14B 차감 후 = $81B"

    why_now:
      title: 왜 지금인가
      lead: 3가지 시장 신호가 동시에 우리를 가리킵니다.
      cards:
        - { stat: "30~50%", label: "Gen AI 실패율",         source: "Gartner 2024-2025", body: "거품이 빠지는 LLM. \"증명 가능한 AI\" 수요 ↑" }
        - { stat: "€17B",   label: "EU AI Act 컴플라이언스", source: "EU Commission",      body: "투명성 규제 시행. SHAP 기반 XAI 필수" }
        - { stat: "85%",    label: "기업 LLM 금지율",       source: "Cisco AI Survey",   body: "데이터 보안. 온프레미스만 가능" }

    funnel:
      title: 우리가 닿을 수 있는 시장
      lead: 전체 시장은 크지만, 1차 목표는 현실적입니다.
      tam: { value: "$81B", label: "TAM — 글로벌 잠재" }
      sam: { value: "$18B", label: "SAM — 비즈니스 분석 SaaS" }
      som: { value: "$500M", label: "SOM — Y3 한국·동남아 SME" }
      target_callout: "Y3 ARR ₩30억 = SOM의 단 0.46% 점유"

    sources:
      title: 이 모든 숫자의 출처
      lead: 8개 1차 리서치 소스. 클릭하여 원문 보기.
      items:
        - { org: "MarketsandMarkets",     quote: "DI $13.3B → $50.1B (CAGR 24.7%)",  year: 2024, url: "https://www.marketsandmarkets.com/PressReleases/decision-intelligence.asp" }
        - { org: "Grand View Research",   quote: "DI $15.22B → $36.34B (CAGR 15.4%)", year: 2024, url: "https://www.grandviewresearch.com/industry-analysis/decision-intelligence-market-report" }
        - { org: "Grand View Research",   quote: "XAI $7.79B → $21.06B (CAGR 18%)",   year: 2024, url: "https://www.grandviewresearch.com/industry-analysis/explainable-ai-market-report" }
        - { org: "Research and Markets",  quote: "Prescriptive $37.05B (CAGR 22%)",   year: 2024, url: "https://www.researchandmarkets.com/reports/5933907/prescriptive-analytics-market-report" }
        - { org: "Gartner",               quote: "30% Gen AI projects abandoned by end 2025", year: 2024, url: "https://www.gartner.com/en/newsroom/press-releases/2024-07-29-gartner-predicts-30-percent-of-generative-ai-projects-will-be-abandoned-after-proof-of-concept-by-end-of-2025" }
        - { org: "EU Commission",         quote: "AI Act 2026-08 시행, €17B compliance market by 2030", year: 2024, url: "https://digital-strategy.ec.europa.eu/en/policies/regulatory-framework-ai" }
        - { org: "Statista",              quote: "SEA SaaS $3.2B → $8.6B (CAGR 22%)", year: 2025, url: "https://www.statista.com/outlook/tmo/public-cloud/southeast-asia" }
        - { org: "한국 정부",              quote: "5년 AI 투자 $71.5B (2025-08 발표)", year: 2025, url: "https://www.investkorea.org/ik-en/bbs/i-5025/detail.do?ntt_sn=490804" }

    cta:
      title: VC 미팅에 가져가실 분?
      lead: 5페이지 리서치 PDF로 30초 안에 답하세요.
      pdf_button: "$81B 근거 PDF 받기"
      demo_button: "5분 데모 보기"
```

### 4.2 영문은 동일 키 구조로 번역 — 한 페이지 양면 미러링

---

## 5. 홈페이지 다른 곳 반영 (작은 손길)

### 5.1 홈 페이지 (`/`) Hero 아래 시장 지표 5개 확장

기존 5 indicator 카드 옆에 "더 자세히" 링크 추가:

```erb
<div class="mt-6 text-center">
  <%= link_to "이 숫자들의 근거 →", market_path(locale: I18n.locale),
        class: "text-[14px] font-semibold", style: "color:#2563EB;" %>
</div>
```

### 5.2 Investors 페이지 — 30초 요약 카드 추가

`pages/investors.html.erb` 상단 (Pre-Seed Ask 위)에:

```erb
<div class="card" style="padding:24px; background:#0B132D; color:#fff; margin-bottom:24px;">
  <div class="font-mono text-[11px]" style="color:#00C8C8; letter-spacing:0.14em;">// 30초 요약</div>
  <h3 class="h-card mt-2" style="color:#fff;">우리 시장은 $81B</h3>
  <p class="mt-3 text-[14px]" style="color:#a7b1c7; line-height:1.65;">
    Decision Intelligence + XAI + Prescriptive Analytics 합산 TAM.
    보수적으로는 $50.1B (MarketsandMarkets 단독, CAGR 24.7%).
  </p>
  <%= link_to "→ 합산 근거 보기", market_path(locale: I18n.locale),
        class: "text-[14px] font-semibold mt-3 inline-block", style: "color:#00C8C8;" %>
</div>
```

### 5.3 Vision 페이지 — Phase별 시장 사이즈 매핑

기존 3 Phase 카드에 "이 단계의 시장 사이즈" 한 줄 추가:
- Phase 1 (LLM 도구 레이어): "DI $50.1B 안의 API 슬롯 — 우리 목표"
- Phase 2 (에이전트 백엔드): "AI Governance $5.6B + 인접 영역"
- Phase 3 (Decision Intelligence OS): "$81B 전체 시장의 카테고리 리더 위치"

---

## 6. nav 메뉴 변경

현재:
```
솔루션 / 작동 원리 / 산업별 활용 / 가격 / 팀
```

변경 (Company 드롭다운 또는 단일 추가):
```
솔루션 / 작동 원리 / 산업별 활용 / 가격 / 시장 / 팀
```

또는 더 깔끔하게 — Company 하위 메뉴 신설:
```
솔루션 / 작동 원리 / 산업별 활용 / 가격 / Company ▾
                                                  ├ 시장 가치
                                                  ├ 팀
                                                  └ 비전
```

→ **권장**: 1차로는 단일 메뉴 "시장" 추가 (단순). Company 드롭다운은 v2.

---

## 7. 인터랙티브 컴포넌트 상세 — `MarketScenarioToggle`

### 7.1 Stimulus 컨트롤러
```javascript
// app/javascript/controllers/market_scenario_controller.js
export default class extends Controller {
  static targets = ["tab", "panel", "value", "formula", "body"]
  static values = {
    scenarios: { type: Object, default: {
      bull:  { value: "$81B",   formula: "DI($43B) + XAI($21B) + Prescriptive 비중복($17B)",
               body: "...", color: "#10B981" },
      base:  { value: "$50.1B", formula: "MarketsandMarkets DI 단독",
               body: "...", color: "#00A1E0" },
      worst: { value: "$36.3B", formula: "Grand View DI 단독",
               body: "...", color: "#F59E0B" }
    }}
  }

  switch(event) {
    const which = event.currentTarget.dataset.scenario
    const data = this.scenariosValue[which]
    this.valueTarget.textContent = data.value
    this.valueTarget.style.color = data.color
    this.formulaTarget.textContent = data.formula
    this.bodyTarget.textContent = data.body
    this.tabTargets.forEach(t => t.classList.toggle("active", t.dataset.scenario === which))
  }
}
```

### 7.2 UI 구조
```
[ Bull ] [ Base ] [ Worst ]    ← 탭 3개 (Stimulus action)

┌─────────────────────────────────────┐
│  $81B    ← 큰 숫자                  │
│                                     │
│  Formula box (등폭 폰트)            │
│  DI($43B) + XAI($21B) + ...        │
│                                     │
│  설명 단락                          │
│                                     │
│  "0.46%만 점유해도 ARR ₩30억"      │
└─────────────────────────────────────┘
```

---

## 8. 작업 분해 (4시간 예상)

| # | 작업 | 시간 |
|---|---|---|
| M-001 | 라우트 + 컨트롤러 + i18n YAML (ko/en) | 30분 |
| M-002 | `MarketScenarioToggleComponent` (Stimulus 포함) | 45분 |
| M-003 | `MarketVennComponent` SVG (3원 + 중복) | 30분 |
| M-004 | `MarketFunnelComponent` SVG (TAM→SAM→SOM) | 30분 |
| M-005 | `/company/market` 페이지 7섹션 조립 | 60분 |
| M-006 | 홈 Hero indicator 확장 + Investors 30초 카드 | 20분 |
| M-007 | Nav 메뉴 "시장" 추가 | 5분 |
| M-008 | RSpec 시나리오 (한/영 200 + 핵심 카피 + 시나리오 토글) | 30분 |
| M-009 | 11차 배포 + 외부 검증 + 스크린샷 | 20분 |

---

## 9. 외부 효과 — 누가 본다면

| 청자 | 페이지에서 얻는 것 | 다음 액션 |
|---|---|---|
| **VC** | "$81B 근거를 미팅 전에 셀프 학습" → 미팅 시간 절약 | PDF 다운로드 → 미팅 |
| **기업 의사결정자** | "우리 분야가 이만큼 큰 시장이구나" 신호 | /use-cases → 데모 |
| **언론·분석가** | 인용 가능한 정량 데이터 + 8개 출처 | 기사·리포트 인용 |
| **잠재 직원** | "이 회사가 노리는 그림이 명확하구나" | /company/team → 채용 문의 |
| **파트너 (MCP 개발자)** | Phase별 시장 사이즈 → ROI 가늠 | /platform-api → 문의 |

---

## 10. 한 줄 요약

> **"보고서의 30초 답변 스크립트를, 방문자가 30초에 셀프 학습할 수 있는 페이지로 옮긴다."**
> URL: `/ko/company/market` · `/en/company/market`
> 한 페이지에 시나리오 토글 + 합산 벤다이어그램 + Funnel + 출처 8개 + PDF 다운로드 + 데모 CTA.

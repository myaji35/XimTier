# M3.5 W2 — Brand Governance + 케이스스터디 + 시장 페이지 + Code Wiki 보고서

> 완료: 2026-05-13 / CTO
> 베이스: W1 (`9a4bad5`) → 11차 배포 (`01e2f30`) 외부 라이브

## 1. W2 + 추가 작업 산출물 요약

| 영역 | 산출물 | 상태 |
|---|---|---|
| Harness | brand-dna `_governance` 섹션 v0.3.0 + `_workspace/brand-changelog.md` | ✅ |
| Harness | copy-lint hook + CI 통합 (`config/locales/**` 금지어 검출) | ✅ |
| Harness | brand-dna-guard hook (approval_required_for 감지) | ✅ |
| 홈페이지 | Tweaks Panel 우하단 (4 옵션 + localStorage) | ✅ |
| 홈페이지 | 4 산업 케이스스터디 페이지 + 라우트 + 한/영 i18n | ✅ |
| 홈페이지 | Pricing 비교 매트릭스 확장 (12 feature × 4 tier) | ✅ |
| 홈페이지 | Hero CTA 깨진 라우팅 fix (#demo/#investors → 정식 path) | ✅ |
| **시장 페이지** | `/company/market` 신규 7섹션 페이지 + 컴포넌트 3개 | ✅ |
| **Code Wiki** | `/admin/code_wiki` Avo Tool + CodeWikiInspector 서비스 | ✅ |
| 가독성 fix | CardComponent 라이트 톤으로 재구성 (#86) | ✅ |

## 2. 시장 페이지 7섹션 외부 검증 (`/company/market`)

| 섹션 | 컴포넌트 | 외부 확인 |
|---|---|---|
| 1. Hero (다크) | KPI 4카드 — $81B / $50.1B / $36.3B / +28.5% | ✅ |
| 2. 시나리오 토글 | `MarketScenarioToggleComponent` + Stimulus | ✅ |
| 3. 합산 벤다이어그램 | `MarketVennComponent` SVG (DI/XAI/Prescriptive) | ✅ |
| 4. Why Now (다크) | 30~50% / €17B / 85% 정량 카드 | ✅ |
| 5. TAM→SAM→SOM Funnel | `MarketFunnelComponent` SVG 동심원 | ✅ |
| 6. 출처 8개 카드 | M&M / Grand View / Gartner / EU 등 | ✅ |
| 7. CTA (다크) | IR PDF + 데모 신청 버튼 | ✅ |

## 3. 외부 라이브 URL (11차 배포 PASS)

배포 SHA: `01e2f30` (Finished all in 205.7s)

| 카테고리 | URL | 결과 |
|---|---|---|
| Health | `/up` | 200 |
| 마케팅 | `/ko`, `/en` | 200 |
| **시장 페이지** | `/ko/company/market`, `/en/company/market` | **200** |
| 케이스스터디 | `/ko/cases/{manufacturing,hospital,public,smart-city}` | 200 (4/4) |
| Pricing | `/ko/pricing` (매트릭스 포함) | 200 |
| Problem | `/ko/problem` (가독성 fix 적용) | 200 |
| Investors | `/ko/company/investors` (30초 요약 카드) | 200 |

## 4. 누적 RSpec (W1 → W2)

| Spec | 케이스 |
|---|---|
| `spec/requests/pages_spec.rb` | 29 |
| `spec/requests/contact_spec.rb` | 3 |
| `spec/requests/downloads_spec.rb` | 3 |
| `spec/requests/demo_requests_spec.rb` | 8 |
| `spec/requests/how_it_works_spec.rb` | 3 |
| `spec/requests/case_studies_spec.rb` | **13 (W2)** |
| `spec/requests/market_page_spec.rb` | **6 (W2)** |
| **합계** | **65 examples / 0 failures** |

## 5. 새 컴포넌트 (W2에서 추가된 ViewComponent)

| 컴포넌트 | 역할 |
|---|---|
| `MarketScenarioToggleComponent` | Bull/Base/Worst 탭 Stimulus |
| `MarketVennComponent` | 3원 벤다이어그램 SVG |
| `MarketFunnelComponent` | TAM/SAM/SOM 동심원 SVG |
| `CardComponent` (재작성) | 라이트 톤 가독성 회복 |

## 6. Code Wiki (`/admin/code_wiki`)

**Avo Tool** — admin 권한 필수.

### 6.1 라이브 표시 정보
- 환경 (Rails / Ruby / Git SHA / branch)
- ViewComponents 목록 + 줄수 + 템플릿 유무
- Stimulus 컨트롤러 목록 + identifier
- Rails Controllers + Models
- Page 뷰
- i18n locales (한/영 파일 수 + 키 수)
- Harness agents (.claude/agents/*.md)
- Harness issues 통계 (상태별/우선순위별)
- 누적 학습 패턴 개수

### 6.2 사용처
- 신규 개발자 온보딩 (코드 구조 한눈에)
- Admin 운영 중 코드 상태 점검
- Harness 이슈 처리 우선순위 시각 확인

## 7. Brand Governance 신설

### 7.1 brand-dna.json v0.3.0 → `_governance` 섹션
```json
"_governance": {
  "owner": "강승식 (CTO)",
  "design_lead": "한일 (CEO)",
  "approval_required_for": [
    "brand.name", "brand.tagline_ko/en", "brand.positioning",
    "design_tokens.colors.xim_blue", "design_tokens.colors.teal_mint",
    "design_tokens.colors.deep_navy", "design_tokens.gradients.brand",
    "design_tokens.typography.font_family_sans"
  ],
  "auto_iterable": ["radius", "shadow", "motion", "layout", "page_priorities"],
  "review_cadence": "주 1회 (목요일)",
  "lock_until": "2026-09-30",
  "frozen_principles": [
    "X 심볼 4-blade 구조",
    "Blue→Teal 135deg 그라디언트 방향",
    "Decision Intelligence, Proven by Numbers 포지셔닝",
    "voice 4어"
  ]
}
```

### 7.2 자동화 hook
- `copy-lint.sh` — 금지어 ("혁신적/최첨단/차세대/game-changing/revolutionary") 검출. CI 통합
- `brand-dna-guard.sh` — git diff에 approval_required_for 키 변경 감지

## 8. M3.5 W3 다음 작업 (대표님 결정 대기)

| ID | 작업 | 결정 대기 |
|---|---|---|
| W3-001 | 정식 도메인 결정 + DNS 변경 | `.com / .ai / .co.kr` 중 선택 |
| W3-002 | Let's Encrypt SSL 인증서 | 도메인 확정 후 |
| W3-003 | Production SMTP 활성 (Postmark/SendGrid/SES) | 인프라 선택 |
| W3-004 | Plausible Analytics self-host or cloud | 선택 |
| W3-005 | Sentry error tracking | 무료 plan OK |
| W3-006 | OG 이미지 자동 생성 | Rails Image Processing |
| W3-007 | JSON-LD 구조화 데이터 | 옵션 |

## 9. 한 줄 요약

> **"W2에서 케이스스터디 + 시장 페이지 + Code Wiki + Brand 거버넌스를 한 번에 외부로 내보냈다. $81B TAM의 근거를 방문자가 셀프 학습 + Admin이 코드 상태를 실시간 모니터링하는 운영 인프라까지 갖춤."**

---

## 10. 산출 파일 변경 요약 (commit `01e2f30`)

**추가:**
- `app/components/market_{scenario_toggle,venn,funnel}_component.{rb,html.erb}` (6)
- `app/javascript/controllers/market_scenario_controller.js`
- `app/services/code_wiki_inspector.rb`
- `app/controllers/avo/tools_controller.rb`
- `app/views/avo/tools/code_wiki.html.erb` + sidebar item
- `app/views/pages/market.html.erb`
- `app/views/pages/case_study.html.erb`
- `app/views/shared/_tweaks_panel.html.erb`
- `app/javascript/controllers/tweaks_controller.js`
- `config/locales/{ko,en}/market_page.yml` + `cases.yml`
- `_workspace/{brand-changelog,market-page-spec,w2-report}.md`
- `_workspace/screenshots/{w1-*,brand-rename-*,card-readability-*,prod-market-page}.png`
- `.claude/hooks/{copy-lint,brand-dna-guard}.sh`
- `spec/requests/{case_studies,market_page}_spec.rb`

**수정:**
- `brand-dna.json` v0.3.0 (_governance 신설)
- `app/components/card_component.{rb,html.erb}` — 라이트 톤 재구성
- `app/views/pages/{home,investors,use_cases,pricing}.html.erb`
- `app/views/layouts/application.html.erb` — Nav 시장 메뉴 + Tweaks 마운트
- `config/locales/{ko,en}/{site,pricing,contact}.yml`
- `config/routes.rb` — market + case_study + comments routes
- `.github/workflows/ci.yml` — copy-lint job 추가

41개 파일 / commit `01e2f30` / push 완료 (origin/main).

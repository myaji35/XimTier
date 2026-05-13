# M3.5 W1 — Foundation + Reverse What-If 보고서

> 완료: 2026-05-13 / CTO
> 베이스: 8차 배포 (MVP) → 9차 배포 (W1 Reverse What-If)

## 1. 산출물 요약

| 영역 | 산출물 | 상태 |
|---|---|---|
| Harness | `.claude/` 전체 설치 (CLAUDE.md / hooks / agents / brand-dna / settings) | ✅ |
| Harness | `registry.json` v3 + W1 issues 5개 + M3 학습자산 4개 등록 | ✅ |
| 데모 | Stimulus `reverse_what_if_controller.js` (5변수 + SHAP solve) | ✅ |
| 데모 | `_reverse_what_if_demo.html.erb` (Target 카드 + 슬라이더 + 5변수 카드 + SHAP bars) | ✅ |
| 데모 | `/ko/how-it-works`, `/en/how-it-works` 임베드 | ✅ |
| 데모 | 한/영 i18n (`demo.yml` 양쪽) + "예시 데이터" 워터마크 | ✅ |
| 폴리쉬 | Hero floating chips 5-7s staggered 애니메이션 (reduce-motion 존중) | ✅ |
| 테스트 | RSpec 51 / 0 fail (`how_it_works_spec.rb` 3 신규) | ✅ |

## 2. 검증

### 2.1 로컬 (`http://localhost:3019/ko/how-it-works`)
- ✅ 라이브 데모 섹션 노출
- ✅ 슬라이더 드래그 → 5변수 카드 즉시 업데이트 (≤16ms)
- ✅ SHAP 탭 클릭 → 양/음 막대 + 중앙 0선 시각화
- ✅ 콘솔 에러 0건

### 2.2 시각 증거
- `screenshots/w1-reverse-demo-v2.png` — Reverse 탭 5변수 카드
- `screenshots/w1-shap-tab.png` — SHAP 탭 양/음 막대

### 2.3 외부 (9차 배포 PASS)
- 배포 SHA: `d6f4a2e` (Finished all in 167.4s)
- 외부 URL: http://ximtier.158.247.235.31.nip.io/ko/how-it-works
- 외부 검증: `/up` 200 / `/ko/how-it-works` 200
- 데모 섹션 노출: ✅ (`reverse-what-if-demo` / `라이브 데모` / `OPTIMAL INPUTS` / `FEATURE IMPACT` / `case_01`)
- 슬라이더 + 5변수 계산: ✅ 외부 chrome-devtools 스크린샷 (`screenshots/w1-prod-reverse.png`)
- 콘솔 에러: 0건
- Lighthouse Performance: ⏳ W2 시작 전 측정 예정

## 3. Harness 효과 측정

### 3.1 이슈 처리 통계
| 메트릭 | 값 |
|---|---|
| 등록 이슈 | 5개 (ISS-001~005) |
| 자동 처리 | 4개 (ISS-001~004) |
| Hooks 발화 | on_complete (수동), 다음 W2 자동화 예정 |
| 학습 자산 추가 | M3 패턴 4개 (success_patterns) |

### 3.2 다음 자동화 (W2~W4)
- W2: `marketing-copywriter` agent로 i18n YAML 자동 lint
- W2: `seo-optimizer` agent로 신규 페이지 meta 자동 보강
- W3: `dx-engineer` agent로 캐릭터 저니 회귀 (Playwright)
- W4: Admin Harness Dashboard 위젯 → 이슈 카드 + 실행 버튼

## 4. 다음 주(W2) 작업

| ID | 이슈 | 우선순위 |
|---|---|---|
| W2-001 | Tweaks Panel (4종 토글 + localStorage) | P0 |
| W2-002 | 4개 산업 케이스스터디 페이지 + RSpec | P0 |
| W2-003 | Pricing 비교 매트릭스 확장 | P1 |
| H-005 | brand-dna `_governance` 섹션 | P1 |
| H-006 | brand-dna diff 감지 hook | P2 |
| H-007 | 카피 lint 자동화 | P2 |

## 5. 산출 파일

```
app/javascript/controllers/reverse_what_if_controller.js  (+121 lines)
app/views/shared/_reverse_what_if_demo.html.erb           (+103 lines)
app/views/pages/how_it_works.html.erb                     (+11 lines, embed)
app/views/pages/home.html.erb                             (+1 line, float-chip class)
app/assets/tailwind/application.css                       (+17 lines, keyframes)
config/locales/ko/demo.yml                                (new, 20 keys)
config/locales/en/demo.yml                                (new, 20 keys)
spec/requests/how_it_works_spec.rb                        (new, 3 specs)
.claude/issue-db/registry.json                            (W1 5 issues + M3 patterns)
.claude/ 전체                                              (Harness v4 설치)
```

## 6. 한 줄 요약

> **"5초 안에 슬라이더 한 번으로 ChatGPT가 구조적으로 못 푸는 Reverse What-If를 보여준다 — XimTier의 차별점이 비주얼로 증명됨."**

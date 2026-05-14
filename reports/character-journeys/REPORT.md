# Character Journey QA Report — XIM-21

**Date:** 2026-05-14
**Issue:** XIM-21 — QA: 캐릭터 저니 Playwright 시나리오 4개 (김상무/박사무관/Sarah/Investor)
**Test method:** Live Playwright (MCP) on `http://localhost:3000` against current `main` (Rails 8.1.3 / Puma)
**Persisted specs:** `spec/journeys/*.spec.js` (4 files) — re-runnable via `npm test`

---

## Summary

| # | Persona | Steps | Result | Evidence |
|---|---------|-------|--------|----------|
| 1 | 김 상무 (제조 SME 임원) | 6 | **PASS** | `screenshots/j1-kim-*.png` + Download id=2, DemoRequest id=2, User id=3 |
| 2 | 박 사무관 (공공기관 정책 담당) | 4 | **PASS** | `screenshots/j2-park-*.png` + ContactInquiry id=2 |
| 3 | Sarah (Anthropic MCP 개발자) | 4 | **PASS** | `screenshots/j3-sarah-*.png` + DemoRequest id=3 (EN locale) |
| 4 | Investor (Pre-Seed VC) | 3 | **PASS** | `screenshots/j4-investor-*.png` + Download id=3 + PDF served (200/application/pdf) |

**총 17 스크린샷 / 5개 DB 레코드 검증 / 1개 부수 콘솔 에러 감지** — 별도 이슈 분리 권고.

---

## Journey 1 — 김상무 (제조 SME 임원, 한글)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL | 스크린샷 |
|------|------|----------|----------|-----------|---------|
| 1 | `GET /ko` 진입 | 랜딩 200, Hero 노출 | 200 OK, 타이틀 "XimTier — Decision Intelligence" | ✅ | `j1-kim-s1-landing.png` |
| 2 | `GET /ko/company/investors` | IR 게이트 폼 노출 | 200, name/email/company/role 필드 노출 | ✅ | `j1-kim-s2-investors.png` |
| 3 | 폼 입력 (김상무 / 현대정밀공업 / 상무) | 입력값 반영 | DOM에 정상 반영 | ✅ | `j1-kim-s3-form-filled.png` |
| 4 | 제출 (`POST /ko/company/investors`) | 302 → `?sent=1` + 토큰 발급 | URL `?sent=1`, "이메일로 다운로드 링크" 노출, Download id=2 + token `d862ae8dce…` 생성 | ✅ | `j1-kim-s4-ir-success.png` |
| 5 | `/ko/demo` 폼 입력 + 산업=manufacturing | 입력 반영 | DOM 반영 | ✅ | `j1-kim-s5-demo-filled.png` |
| 6 | 제출 → `/ko/dashboard` 자동 진입 | Devise 자동 가입, PENDING 상태 노출 | URL `/ko/dashboard`, body에 "대기" 매칭, User id=3 + DemoRequest id=2 생성 | ✅ | `j1-kim-s6-dashboard.png` |

**부수 검증:** `curl -I /ko/ir/d862ae8dc…` → `HTTP/1.1 200 OK`, `content-type: application/pdf`, `content-disposition: inline; filename="XimTier_ir_deck_ko.pdf"`. IR PDF 게이트가 토큰 단위로 작동함을 확인.

---

## Journey 2 — 박사무관 (공공기관 정책 담당, 한글)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL | 스크린샷 |
|------|------|----------|----------|-----------|---------|
| 1 | `GET /ko/use-cases` | 10개 산업 카드 + 케이스 링크 | 10개 `/cases/*` 링크 확인 (manufacturing/hospital/public/smart-city/finance/retail/logistics/energy/education/telecom) | ✅ | `j2-park-s1-usecases.png` |
| 2 | `GET /ko/cases/public` | 공공·정책 케이스 상세 | 200, 타이틀 "광역시 — 청년 실업률 정책 시나리오 시뮬레이션" | ✅ | `j2-park-s2-case-public.png` |
| 3 | `/ko/contact` 폼 작성 (박사무관 / NIPA / public_sector / EU AI Act 메시지) | 입력 반영 | DOM 반영 | ✅ | `j2-park-s3-contact-filled.png` |
| 4 | 제출 → 정상 접수 플래시 | "문의가 정상 접수되었습니다" 노출 + ContactInquiry 레코드 생성 | 플래시 확인, ContactInquiry id=2 (handled=false, industry=public_sector) | ✅ | `j2-park-s4-contact-success.png` |

---

## Journey 3 — Sarah (Anthropic MCP Developer, English)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL | 스크린샷 |
|------|------|----------|----------|-----------|---------|
| 1 | `GET /en` | EN 랜딩, `<html lang="en">` | 200, `lang="en"` 확인 | ✅ | `j3-sarah-s1-en-landing.png` |
| 2 | `GET /en/platform-api` | MCP/OpenAI Plugin 안내 | 200, 본문에 "MCP" + "OpenAI Plugin" 노출 | ✅ | `j3-sarah-s2-platform-api.png` |
| 3 | `/en/demo` 폼 작성 (Sarah Lee / Independent MCP Developer / other / Wolfram Alpha 언급) | 입력 반영 | DOM 반영 | ✅ | `j3-sarah-s3-demo-filled.png` |
| 4 | 제출 → `/en/dashboard` 자동 진입 | EN locale 유지 + 자동 가입 | URL `/en/dashboard`, 타이틀 "My demo requests", DemoRequest id=3 생성 | ✅ | `j3-sarah-s4-en-dashboard.png` |

---

## Journey 4 — Investor (Pre-Seed VC, 한글)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL | 스크린샷 |
|------|------|----------|----------|-----------|---------|
| 1 | `GET /ko/company/team` | 팀 페이지 노출 | 200, 타이틀 "왜 이 팀이 이 문제를 풀 수 있는가" | ✅ | `j4-investor-s1-team.png` |
| 2 | `GET /ko/company/vision` | 3 Phase 진화 | 200, 타이틀 "3단계 플랫폼 진화" | ✅ | `j4-investor-s2-vision.png` |
| 3 | IR 게이트 (이수정 파트너 / 더벤처스 / Investment Partner) | 토큰 발급 + PDF 서빙 | `?sent=1`, Download id=3, token `4d5b1e83…`, HEAD `/ko/ir/4d5b1e83…` → 200 application/pdf | ✅ | `j4-investor-s3-ir-success.png` |

---

## 사이드 발견 — 별도 이슈 분리 권고

### `count_up_controller` Stimulus 연결 실패 (P2, BUG)
- **증상:** 랜딩 페이지(`/ko`, `/en`) 진입 시 콘솔 에러
  ```
  Error connecting controller TypeError: Cannot set property targets of #<ae> which has only a getter
    at t.connect (count_up_controller-a7bd255d.js:15:18)
  ```
- **영향:** 시각적 회귀 없음 (페이지 렌더 정상). 카운트업 애니메이션이 동작하지 않을 가능성. Slide 4 시장 지표 숫자 카운트업이 PRD FR-2에 명시되어 있어 **기능 회귀**에 해당.
- **권고 액션:** FIX_BUG 자식 이슈 생성 → frontend 에이전트가 `app/javascript/controllers/count_up_controller.*` 검토.

---

## 검증 메타데이터

- **Ruby:** 3.3.10 / Rails 8.1.3 / Puma 8.0.1
- **브라우저:** Playwright Chromium (MCP) @ 1440×900
- **DB 검증:** `bin/rails runner` 직접 조회로 Download / DemoRequest / ContactInquiry / User 테이블 레코드 확인
- **인증 흐름:** Devise + DemoRequestsController가 데모 신청 폼 제출 시 자동 회원가입 + 로그인 + 대시보드 리다이렉트 1-step으로 처리 (PRD FR-5 부합)
- **i18n:** ko/en URL 프리픽스 정상, `<html lang>` 정상, EN/KO 라벨 분리 정상

## 재실행 방법

```bash
cd xaisimtier/spec/journeys
npm install && npx playwright install chromium
BASE_URL=http://localhost:3000 npm test
```
- 매 실행 시 unique email(`Date.now()` suffix)을 사용하므로 중복 충돌 없음
- HTML 리포트: `reports/character-journeys/playwright-html/index.html`

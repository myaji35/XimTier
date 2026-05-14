# Character Journey Playwright Specs

XIM-21 deliverable. 4 personas × 4-step Playwright scenarios validating the public marketing site + auth + admin gateway.

## 페르소나

| # | 페르소나 | 파일 | 핵심 검증 |
|---|----------|------|-----------|
| 1 | 김 상무 — 제조 SME 임원 | `kim-sangmu.spec.js` | KO 랜딩 → IR PDF 다운로드 게이트 → 데모 신청 → 자동 가입 + 본인 대시보드 |
| 2 | 박 사무관 — 공공기관 정책 담당 | `park-samukwan.spec.js` | use-cases → 공공 케이스 상세 → 문의 폼 제출 → 정상 접수 메시지 |
| 3 | Sarah — Anthropic MCP 개발자 | `sarah-mcp-dev.spec.js` | EN 랜딩 → /en/platform-api(MCP) → EN 데모 신청 → EN 대시보드 |
| 4 | Investor (더벤처스/스파크랩) | `investor.spec.js` | 팀 → 비전 → IR 다운로드 게이트 (이메일+회사) → 토큰 404 음성 케이스 |

## 실행

```bash
# 1) Rails 서버 띄우기 (별도 터미널)
bin/rails server

# 2) Playwright 의존성 설치
cd spec/journeys
npm install
npx playwright install chromium

# 3) 전체 저니 실행
npm test

# 4) 헤드풀(브라우저 보면서)
npm run test:headed

# 5) HTML 리포트
npm run report
```

스크린샷은 `reports/character-journeys/screenshots/` 에 `j{N}-{persona}-s{step}-*.png` 형식으로 저장된다.
HTML 리포트는 `reports/character-journeys/playwright-html/`.

## 인증 흐름 메모

데모 신청 폼(`/{locale}/demo`)은 Devise + DemoRequestsController에서 폼 데이터로 자동 회원가입 + 로그인 처리한다.
이메일은 매번 `Date.now()` 접미사로 unique하게 생성하므로, 같은 페르소나를 여러 번 돌려도 충돌 없음.

## 알려진 콘솔 에러 (별도 이슈로 추적)

- `count_up_controller`: `Cannot set property targets of #<ae> which has only a getter` — 랜딩 페이지 진입 시 Stimulus 컨트롤러 연결 실패. 시각적 동작에는 영향 없으나 카운트업 애니메이션이 동작하지 않음. **별도 FIX_BUG 이슈로 분리할 것**.

## PASS/FAIL 보고서

`reports/character-journeys/REPORT.md` 참조.

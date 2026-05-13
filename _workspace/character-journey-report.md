# XimTier 캐릭터 저니 검증 보고서 (M3 MVP)

> 작성: 2026-05-13 / CTO
> 검증 환경: 로컬 :3019 (dev) + http://ximtier.158.247.235.31.nip.io (prod 8차 후)

## 페르소나 5종 (PRD §2)

| # | 페르소나 | 진입 동기 | 주요 액션 | 언어 |
|---|---|---|---|---|
| 1 | **김 상무** — 제조 SME 임원 | "ChatGPT 입력 금지인데 분석은 필요" | 데모 신청 | 한글 |
| 2 | **박 사무관** — 공공 정책 담당 | NIPA 사업 + XAI 의무화 | 사례 + 문의 | 한글 |
| 3 | **Sarah** — Anthropic MCP 개발자 | "Wolfram Alpha 같은 계산 서버" | API 문서 + MCP 안내 | English |
| 4 | **Investor** — 더벤처스 심사역 | Pre-Seed 검토 | IR PDF 다운로드 | 한글/영문 |
| 5 | **Admin** — 운영팀 | 리드 + 콘텐츠 관리 | Avo Admin | 한글 |

---

## 저니 1: 김상무 (제조 SME, 한글)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL |
|---|---|---|---|---|
| 1 | `http://ximtier.158.247.235.31.nip.io/` 진입 | Accept-Language=ko → `/ko` 리디렉트 | 301 → `/ko` | ✅ |
| 2 | Hero 메시지 확인 | "LLM이 못 푸는 수치를, 우리가 증명한다" | 그라디언트 헤드라인 표시 | ✅ |
| 3 | nav "산업별 활용" 클릭 | `/ko/use-cases` 200 | 제조 카드 노출 | ✅ |
| 4 | "데모 신청" CTA 클릭 | `/ko/demo` 폼 | 6필드 + 동의 체크 | ✅ |
| 5 | 폼 작성 + 제출 | 자동 가입 + 302 `/ko/dashboard` | User+DemoRequest 생성 | ✅ |
| 6 | 대시보드 진입 | "접수 완료 — 일정 조율 중" 상태 + 신청 내용 | 정상 출력 | ✅ |
| 7 | 메일함 확인 | welcome (임시 PW) + received | letter_opener 2통 도착 | ✅ |

**스크린샷:** `screenshots/m3-demo-form.png`

---

## 저니 2: 박사무관 (공공 정책, 한글)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL |
|---|---|---|---|---|
| 1 | `/ko/use-cases` 탐색 | "공공 — 정책 시나리오 시뮬레이션" 카드 | NIPA 적합/PoC 본도입 출력 | ✅ |
| 2 | nav "문의하기" | `/ko/contact` 폼 200 | 산업 select에 "공공·행정" 선택 | ✅ |
| 3 | 문의 폼 작성 + 제출 | DB 저장 + 자동회신 + Admin 알림 | 302 + ContactInquiry +1 | ✅ |
| 4 | (Admin 측) Avo `/admin` | 새 문의 노출 | resource 등록됨 | ✅ |

---

## 저니 3: Sarah (영문 개발자)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL |
|---|---|---|---|---|
| 1 | `Accept-Language: en` → `/` | `/en` 리디렉트 | 301 → `/en` | ✅ |
| 2 | Hero 영문 | "We prove the numbers LLMs can't." | 그라디언트 표시 | ✅ |
| 3 | nav "Platform API" 클릭 | `/en/platform-api` 200 | MCP/Plugin 안내 + Coming Soon | ✅ |
| 4 | KO/EN 토글 | `/en` ↔ `/ko` 전환 | 우상단 KO/EN 링크 | ✅ |
| 5 | `/en/company/investors` 진입 | IR download form | 영문 라벨 | ✅ |
| 6 | 영문 폼 제출 | 토큰 발급 + 영문 메일 | Download +1 | ✅ |

---

## 저니 4: Investor (Pre-Seed VC)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL |
|---|---|---|---|---|
| 1 | `/ko/company/investors` | "Pre-Seed ₩3억" + Use of Funds | 풀 페이지 출력 | ✅ |
| 2 | 다운로드 폼 작성 + 제출 | 토큰 발급 메일 | Download +1, token 20byte hex | ✅ |
| 3 | 메일의 다운로드 링크 클릭 | `/ko/ir/{token}` → PDF | 365KB / 12페이지 응답 | ✅ |
| 4 | 다운로드 카운트 확인 | downloaded_count +1 | DB 정상 증가 | ✅ |
| 5 | `/ko/company/team` 진입 | 한일/강승식 카드 | 팀 강점 3행 출력 | ✅ |
| 6 | `/ko/company/vision` 진입 | 3 Phase 82%/58%/28% | progress bar 정상 | ✅ |

---

## 저니 5: Admin (운영팀)

| 스텝 | 행동 | 기대 결과 | 실제 결과 | PASS/FAIL |
|---|---|---|---|---|
| 1 | `User.first.update(admin: true)` | DB 변경 | ✅ |
| 2 | Devise 로그인 → `/admin` | Avo 대시보드 진입 | 200 (admin=false면 sign_in 리디렉트) | ✅ |
| 3 | "DemoRequests" 리소스 | 리스트 + 검색/필터 | 모든 신청 표시 | ✅ |
| 4 | DemoRequest 편집 → status: scheduled + meeting_url | 저장 시 사용자 대시보드 반영 | ✅ |
| 5 | "ContactInquiries" | unhandled 필터 + handled 토글 | 작동 | ✅ |
| 6 | "Downloads" | downloaded_count, asset 표시 | ✅ |
| 7 | "Comments" | DemoRequest 별 코멘트 | ✅ |
| 8 | "Users" 검색 (email/name) | 결과 출력 | ✅ |

---

## 통합 PASS/FAIL 매트릭스

| 저니 | 단계 수 | PASS | FAIL |
|---|---|---|---|
| 김상무 (제조) | 7 | 7 | 0 |
| 박사무관 (공공) | 4 | 4 | 0 |
| Sarah (영문 개발자) | 6 | 6 | 0 |
| Investor (VC) | 6 | 6 | 0 |
| Admin (운영팀) | 8 | 8 | 0 |
| **합계** | **31** | **31** | **0** |

---

## 자동화 시나리오 (RSpec 보강)

| Spec | 케이스 |
|---|---|
| `spec/requests/pages_spec.rb` | 29 (한/영 13페이지 + 헬스 + 리디렉트) |
| `spec/requests/contact_spec.rb` | 3 |
| `spec/requests/downloads_spec.rb` | 3 |
| `spec/requests/demo_requests_spec.rb` | 8 (Demo 4 + Dashboard 2 + Comments 2) |
| **합계** | **43 examples / 0 failures** |

전체 RSpec: `48 examples / 0 failures / 5 pending`.

---

## 미해결 / 차후 개선

1. **이메일 production SMTP** — 현재 placeholder, 실제 발송 안 됨. SendGrid/Postmark 결정 필요
2. **Devise 가입 시 패스워드 재설정 강제** — 현재는 임시 PW로 무한 사용 가능
3. **Admin은 단일 boolean** — 다단계 권한 매트릭스 필요시 Pundit 정책 확장
4. **IR 토큰 만료** — 현재 무한. 24h/7d 옵션 추가 가능
5. **Avo Comments — by_admin=true 토글 시 사용자 대시보드에 "XimTier 팀"으로 표시되는지** 외부 검증 필요

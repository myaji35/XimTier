# XimTier MVP 상세 명세서 — 데모 신청 + IR 다운로드

> 작성: 2026-05-13 / CTO
> 베이스: M3 (`1f208e1`) + M3.5 W1 (`9a4bad5`) 외부 라이브
> 범위: Hero CTA 2개 ("데모 신청" + "IR 자료 다운로드") 의 종단 플로우

---

## 0. 정의

| 용어 | 의미 |
|---|---|
| **데모 신청** | 잠재 고객이 `/demo` 폼 제출 → User 자동 생성 → DemoRequest 등록 → 1주 내 미팅 일정 잡힘 |
| **IR 다운로드** | 잠재 투자자/VC가 `/company/investors` 폼 제출 → 토큰 발급 메일 → PDF 다운로드 |
| **Lead** | 두 흐름에서 발생한 모든 외부 접점 (DemoRequest + ContactInquiry + Download) |
| **SQL** (Sales Qualified Lead) | Admin이 검수 후 "유효한 잠재 고객"으로 분류한 Lead |

---

## 1. 데모 신청 (`/demo`) — 상세 플로우

### 1.1 진입점
| 위치 | 컴포넌트 | 행동 |
|---|---|---|
| Hero (`/ko`, `/en`) | "데모 신청" `.btn-grad` | `→ /demo` (이전엔 `#demo` 앵커였음, 수정 필요) |
| Nav 우상단 | "데모 신청" `.btn-primary` (작은 사이즈) | `→ /demo` |
| Solution / How-it-works 페이지 끝 CTA 섹션 | "데모 신청" | `→ /demo` |
| Pricing 카드 ①②③ | tier별 "데모 신청" | `→ /demo?tier=light` (v2 — utm 트래킹) |

### 1.2 폼 필드 스키마

| 필드 | 타입 | 필수 | 검증 | DB 매핑 |
|---|---|---|---|---|
| `demo_request[name]` | text | ✅ | maxlength 100 | `User.name` |
| `demo_request[email]` | email | ✅ | EMAIL_REGEXP | `User.email` (unique) |
| `demo_request[company]` | text | ⛔ | maxlength 100 | `User.company` |
| `demo_request[role]` | text | ⛔ | maxlength 100 | `User.role` |
| `demo_request[industry]` | select | ⛔ default `other` | enum 6종 | `User.industry` |
| `demo_request[data_description]` | textarea | ✅ | maxlength 2000 | `DemoRequest.data_description` |
| `demo_request[data_file]` | file | ⛔ | csv/xlsx/json/txt/pdf, ≤10MB | `DemoRequest.data_file` (Active Storage) |
| `demo_request[preferred_at]` | datetime-local | ⛔ | 미래 시점 | `DemoRequest.preferred_at` |
| `demo_request[consent]` | checkbox | ✅ | "1" required | (저장 안 함, 검증만) |
| `website` | hidden text | ⛔ | **honeypot** (값 있으면 silent drop) | — |

### 1.3 신규/기존 유저 분기

```
POST /demo
  ↓
honeypot 체크 → 채워졌으면 302 (silent drop)
  ↓
consent 체크 → 없으면 422 + 폼 에러
  ↓
User.find_by(email) 조회
  ├─ 존재 → user 재사용, welcome 메일 발송 X
  └─ 없음 → User.create(
              email, name, company, role, industry, locale,
              password: SecureRandom.alphanumeric(16) (임시)
            )
            → DemoMailer.welcome(user, password) 발송
  ↓
DemoRequest 생성 (user 연결, data_description, data_file, preferred_at)
  ↓
DemoMailer.received(@demo_request) (사용자에게 접수 안내 + dashboard URL)
DemoMailer.admin_notification(@demo_request) (admin@ximtier.io에게 알림)
  ↓
sign_in(user) (자동 로그인)
  ↓
302 → /dashboard
```

### 1.4 상태 전이 (DemoRequest.status)

```
[pending] ──────────┐
   │                │
   │ Admin 일정 확정 │ 사용자 취소 요청
   ▼                ▼
[scheduled] ───→ [cancelled]
   │
   │ 미팅 종료 + Admin이 completed로 마킹
   ▼
[completed]
```

| 상태 | 의미 | 사용자 노출 | 다음 액션 |
|---|---|---|---|
| `pending` | 접수 직후 | "접수 완료 — 일정 조율 중" | Admin이 24h 내 일정 잡기 |
| `scheduled` | 일정 + Meeting URL 있음 | "일정 확정" + 링크 + 일시 | 사용자가 참석 |
| `completed` | 미팅 종료 후 | "완료" + 후속 자료 첨부 가능 | follow-up 메일 발송 (v2) |
| `cancelled` | 사용자/Admin 취소 | "취소됨" | 재신청 가능 |

### 1.5 메일 시퀀스 (3통)

| # | 메일 | 트리거 | 수신자 | 발송 시점 | 내용 |
|---|---|---|---|---|---|
| 1 | `DemoMailer.welcome` | User 신규 생성 | 신청자 | 즉시 | 가입 환영 + 임시 비밀번호 + 로그인 링크 |
| 2 | `DemoMailer.received` | DemoRequest 저장 | 신청자 | 즉시 | 접수 확인 + 대시보드 링크 |
| 3 | `DemoMailer.admin_notification` | DemoRequest 저장 | `admin@ximtier.io` | 즉시 | 신청자 정보 + 데이터 설명 + 첨부 |

**v2 추가 예정:**
- Day +1: "데이터 첨부 안 했으면 추가 안내" (data_file이 null인 경우)
- Day +3 (pending인 채): Admin에게 "처리 안 된 신청 있음" 알림
- 미팅 1일 전: 사용자에게 미팅 리마인더 + Zoom 링크 재안내
- 미팅 후 +1일: 후속 자료 발송 + 만족도 설문

### 1.6 Admin 처리 SOP

| 단계 | 시한 | 작업 |
|---|---|---|
| 1. 접수 확인 | 영업일 4시간 내 | `/admin` Avo에서 새 DemoRequest 열어 데이터 확인 |
| 2. 도메인 매칭 | 영업일 4시간 내 | 신청자 산업 + 데이터 설명으로 데모 시나리오 결정 |
| 3. 일정 제안 | 영업일 24시간 내 | 사용자에게 메일로 3개 시간 제안 (현재 수동, v2에 Calendly 통합) |
| 4. 일정 확정 | 사용자 응답 후 즉시 | `status: scheduled` + `scheduled_at` + `meeting_url` 입력 |
| 5. 데모 준비 | 미팅 1일 전 | data_file 분석 + 시연 자료 준비 |
| 6. 미팅 실행 | 예정 시각 | Zoom/Meet 데모 (30~60분) |
| 7. 후속 | 미팅 +1일 | `status: completed` + admin_notes + follow-up 자료 첨부 |

### 1.7 사용자 대시보드 (`/dashboard`)

**제공 정보:**
- 데모 신청 목록 (recent order)
- 각 신청의 상태 배지 (색상 코드)
- `preferred_at`, `scheduled_at`, `meeting_url`, `admin_notes` 노출
- 첨부 파일 다운로드
- 코멘트 스레드 (사용자 ↔ Admin)
- 새 데모 신청 CTA

**비기능:**
- Devise 인증 필수
- 본인 demo_requests만 표시 (`current_user.demo_requests`)
- Comment 도 본인 demo_request 만 작성 가능

### 1.8 에지 케이스

| 케이스 | 처리 |
|---|---|
| 동일 이메일 중복 신청 | 기존 user 재사용, welcome 메일 안 보냄. DemoRequest +1 |
| 첨부 파일 10MB 초과 | Rails 422 (Active Storage 자동) — v2에서 클라이언트 사이드 사전 검증 |
| 미래 아닌 preferred_at | 현재 검증 X (UI에서 datetime-local min 추가 가능) |
| consent 체크 안 함 | 422 + 폼 재렌더 + 에러 메시지 |
| honeypot 채워짐 | 302 redirect with success notice (silent drop, 봇이 모르게) |
| Rack::Attack throttle | 429 ("Throttled. Please retry shortly.") — 분당 5회/IP |
| User.create 실패 (이메일 형식 등) | 422 + User 에러 메시지 → DemoRequest 에러로 합쳐 표시 |
| 미인증 사용자가 대시보드 직접 접근 | 302 → `/users/sign_in` |
| 사용자가 비밀번호 분실 | Devise `:recoverable` (이미 활성) → `/users/password/new` |

### 1.9 KPI 측정

| KPI | 정의 | 측정 도구 | M3.5 목표 |
|---|---|---|---|
| Demo Conversion Rate | `/demo` GET → POST 비율 | Plausible (W3 활성) | ≥ 5% |
| First Lead Time | 첫 POST 발생까지 시일 | DemoRequest.created_at | ≤ 2주 |
| Admin Response SLA | DemoRequest 생성 → status: scheduled | DB 측정 | ≤ 24h (P90) |
| Demo Completion Rate | `scheduled` → `completed` 비율 | DB | ≥ 70% |
| Show-up Rate | 일정 잡은 미팅 중 실참 비율 | Admin 수동 입력 | ≥ 80% |

---

## 2. IR 자료 다운로드 (`/company/investors`) — 상세 플로우

### 2.1 진입점
| 위치 | 컴포넌트 | 행동 |
|---|---|---|
| Hero | "IR 자료 다운로드" `.btn-ghost` | `→ /company/investors` (현재 `#investors` 앵커 → 수정 필요) |
| Nav (옵션, v2) | "투자자" 메뉴 | `→ /company/investors` |
| Investors 페이지 자체 | "다운로드 요청" 폼 제출 버튼 | `→ POST /company/investors` |

### 2.2 폼 필드 스키마

| 필드 | 타입 | 필수 | 검증 | DB 매핑 |
|---|---|---|---|---|
| `download[name]` | text | ✅ | maxlength 100 | `Download.name` |
| `download[email]` | email | ✅ | EMAIL_REGEXP | `Download.email` |
| `download[company]` | text | ⛔ | maxlength 100 | `Download.company` |
| `download[role]` | text | ⛔ | maxlength 100 | `Download.role` |
| `download[asset]` | hidden | ✅ | enum (ir_deck_ko / ir_deck_en / ai_engine_deck) | `Download.asset` |
| `website` | hidden | ⛔ | honeypot | — |

**현재 미적용 (v1.5 추가 예정):**
- `download[marketing_consent]` — 마케팅 활용 별도 동의 (개인정보 동의와 분리)
- reCAPTCHA / Turnstile (Rack::Attack로 충분하지만 보강 가능)

### 2.3 처리 흐름

```
POST /company/investors
  ↓
honeypot 체크
  ↓
Download.find_or_initialize_by(email, asset)
  ├─ 신규 → 새 토큰 (SecureRandom.hex(20)) + 모든 필드 저장
  └─ 기존 → 기존 토큰 재사용 (재요청 시 동일 링크) — *현재 정책*
  ↓
DownloadMailer.link(@download) (다운로드 링크 메일)
  ↓
302 → /company/investors?sent=1 (성공 안내)

---

GET /ir/:token
  ↓
Download.find_by(download_token: params[:token])
  ├─ nil → 302 → /company/investors + alert "유효하지 않거나 만료"
  └─ found:
       @download.increment_download! (downloaded_count +1)
       send_file (Rails.root + public/ir/{asset_file}.pdf, disposition: inline)
```

### 2.4 자산 매핑

| `Download.asset` enum | PDF 파일 | 위치 |
|---|---|---|
| `ir_deck_ko` (0) | `XAISimTier_PitchDeck_v2.pdf` (357KB) | `public/ir/` |
| `ir_deck_en` (1) | `XAISimTier_PitchDeck_v2.pdf` (영문판 미작성 — *현재 동일 파일*) | `public/ir/` |
| `ai_engine_deck` (2) | `XAISimTier_AI_Decision_Engine.pdf` (11MB) | `public/ir/` |

**v1.5 필수:** 영문 IR 자료 별도 제작 (`XimTier_PitchDeck_v2_EN.pdf`) — 현재 한/영 동일 PDF 서빙.

**v2:** 자산을 Active Storage로 이동 → CDN 캐싱 + 버전 관리.

### 2.5 토큰 정책

| 항목 | 현재 (M3 MVP) | v1.5 권장 | v2 |
|---|---|---|---|
| 토큰 길이 | `SecureRandom.hex(20)` = 40자 | 유지 | 유지 |
| 만료 | **무한** (위험) | 7일 (`expires_at` 컬럼 추가) | 24h + 재발급 가능 |
| 중복 발급 | find_or_initialize (재사용) | 만료된 경우 새 토큰 발급 | 재요청 시 새 토큰 (이전 invalidate) |
| 카운트 | `downloaded_count` 증가 (무제한) | 10회 초과 시 차단 + alert | 5회 + IP 트래킹 |

### 2.6 메일 시퀀스

| # | 메일 | 트리거 | 수신자 | 발송 시점 | 내용 |
|---|---|---|---|---|---|
| 1 | `DownloadMailer.link` | Download 저장 | 요청자 | 즉시 | 그라디언트 버튼 CTA + 토큰 URL plain text |

**v2 추가:**
- Day +1: PDF 열어봤지만 응답 없는 경우 follow-up
- Day +3: "데모 신청도 받습니다" 크로스 프로모션
- 다운로드 카운트 5회 초과: Admin alert (관심 높은 lead)

### 2.7 Admin 처리 SOP

| 단계 | 시한 | 작업 |
|---|---|---|
| 1. 신규 Download 확인 | 영업일 8시간 내 | `/admin` Avo에서 새 Download 열기 |
| 2. lead score 평가 | 영업일 24시간 내 | 회사명 + 직책 + 산업으로 우선순위 (VC > 기업 임원 > 일반) |
| 3. 우선 lead 컨택 | 48시간 내 | 메일 직접 발송 (개인화) → "30분 통화 가능?" |
| 4. 미팅 (옵션) | 14일 내 | Zoom/대면 — 데모 신청과 동일 플로우 |

### 2.8 에지 케이스

| 케이스 | 처리 |
|---|---|
| 동일 이메일 + 동일 asset 재요청 | 기존 토큰 재사용 (재발급 안 함) |
| 토큰 URL 직접 변조 시도 | nil → 302 + alert (사용자 친화 메시지) |
| PDF 파일 누락 (서버 측 사라짐) | 302 + alert "관리자 문의" |
| 봇 honeypot | silent drop with 302 |
| Rack::Attack throttle | 429 |
| 마케팅 메일 거부 의사 | (v2) unsubscribe 링크 — 현재는 미적용 |
| EU 방문자 GDPR | (v2) cookie banner + data export request |

### 2.9 KPI 측정

| KPI | 정의 | 측정 도구 | M3.5 목표 |
|---|---|---|---|
| Form Conversion | `/company/investors` GET → POST | Plausible (W3) | ≥ 10% |
| Email Open Rate | 발송 → 열람 | Postmark (W3) | ≥ 40% |
| PDF Open Rate | 토큰 URL 클릭 → GET /ir/:token | DB | ≥ 60% |
| Repeat Download | 동일 이메일 카운트 > 1 비율 | DB | 추적만 (관심도 신호) |
| Lead → Meeting | Download → Demo 신청 또는 미팅 비율 | DB cross-ref | ≥ 5% (VC만 cohort) |

---

## 3. Hero CTA 라우팅 수정 (현재 버그)

### 3.1 발견된 이슈
현재 `app/views/pages/home.html.erb`의 Hero CTA가 **`#demo` / `#investors` 앵커**로 가는데, 이 페이지 안에 해당 ID 섹션이 없어서 **아무 동작도 안 함**.

```erb
<a href="#demo" class="btn btn-grad">데모 신청</a>          ← 깨진 링크
<a href="#investors" class="btn btn-ghost">IR 자료 다운로드</a>  ← 깨진 링크
```

### 3.2 수정 필요
```erb
<%= link_to t("site.hero.cta_demo"), demo_path(locale: I18n.locale), class: "btn btn-grad" %>
<%= link_to t("site.hero.cta_ir"), investors_path(locale: I18n.locale), class: "btn btn-ghost" %>
```

→ **W2 시작 시 first task로 처리**.

---

## 4. 통합 KPI 대시보드 설계 (W4)

| 카드 | 데이터 소스 | 갱신 주기 |
|---|---|---|
| 오늘 신규 데모 신청 | `DemoRequest.where(created_at: today).count` | 5분 |
| 오늘 IR 다운로드 | `Download.where(created_at: today).count` | 5분 |
| 주간 누적 lead | `DemoRequest + ContactInquiry + Download (this_week)` | 1시간 |
| 산업별 분포 (Pie) | `User.group(:industry).count` | 1시간 |
| 한/영 비율 | locale 기반 | 1시간 |
| Admin SLA P90 | `DemoRequest.where(status: scheduled, created_at: last_30days).map(&:scheduled_at - created_at)` | 1일 |
| Active Funnel | new → submitted → scheduled → completed | 1시간 |

---

## 5. 보안 + 컴플라이언스 체크리스트

| 항목 | 데모 | IR | 상태 |
|---|---|---|---|
| Honeypot 봇 차단 | ✅ | ✅ | 적용됨 |
| Rack::Attack throttle | ✅ (5/min/IP) | ✅ | 적용됨 |
| 동의 체크박스 (required) | ✅ | ⛔ (현재 미적용) | **데모만** |
| 마케팅 동의 별도 | ⛔ | ⛔ | v1.5 |
| 개인정보처리방침 링크 | ⛔ (폼 옆) | ⛔ | v1.5 — `/privacy` 본문 작성 후 |
| EU GDPR — Cookie Banner | ⛔ | ⛔ | W4 |
| 토큰 만료 | n/a | ⛔ (무한) | v1.5 |
| 다운로드 카운트 제한 | n/a | ⛔ (무제한) | v1.5 |
| PII 암호화 (at rest) | ⛔ (SQLite 파일 평문) | ⛔ | v2 (Active Record Encryption) |
| SMTP DKIM/SPF | ⛔ | ⛔ | W3 — Postmark 설정 시 |

---

## 6. 시퀀스 다이어그램 (텍스트)

### 6.1 데모 신청 종단 시퀀스
```
사용자       /demo 폼       서버                 메일러           Admin
  │            │            │                    │              │
  │ GET ──────▶│            │                    │              │
  │            │ render 폼  │                    │              │
  │ POST 입력 ─────────────▶│                    │              │
  │            │            │ honeypot ✓          │              │
  │            │            │ consent ✓           │              │
  │            │            │ User.find_or_create │              │
  │            │            │ DemoRequest.save    │              │
  │            │            │ ──→ welcome ──────▶│              │
  │            │            │ ──→ received ─────▶│              │
  │            │            │ ──→ admin ───────────────────────▶│
  │            │            │ sign_in(user)       │              │
  │            │ 302 dash ◀─│                    │              │
  │            │            │                    │ (Admin 처리)  │
  │            │            │ status: scheduled ◀──────────────│
  │            │            │ scheduled_at, meeting_url        │
  │ GET dash ─▶│            │                    │              │
  │            │ 대시보드   │                    │              │
  │ 코멘트 ─▶ │ Comment 저장▶│                    │              │
```

### 6.2 IR 다운로드 종단 시퀀스
```
방문자       /investors        서버              메일러         메일함        토큰 URL
  │            │              │                  │             │             │
  │ GET ──────▶│              │                  │             │             │
  │            │ render 폼    │                  │             │             │
  │ POST ────────────────────▶│                  │             │             │
  │            │              │ honeypot ✓        │             │             │
  │            │              │ Download.fi_or_init│            │             │
  │            │              │ token 발급        │             │             │
  │            │              │ ──→ link ───────▶│ 이메일 도착 ▶│             │
  │            │ 302 sent=1 ◀│                  │             │             │
  │ "메일 확인" 안내           │                  │             │             │
  │            │              │                  │             │             │
  │            │              │ (사용자 메일 클릭)                            │
  │ GET /ir/:token ───────────────────────────────────────────────────▶ ─────▶│
  │            │              │ Download.find_by_token            │           │
  │            │              │ increment_download!               │           │
  │            │              │ send_file PDF ──────────────────────────────▶│
  │ PDF 다운로드 ◀──────────────────────────────────────────────────────────│
```

---

## 7. 구현 상태 매트릭스

| 항목 | M3 (`1f208e1`) | W1 (`9a4bad5`) | v1.5 예정 | v2 예정 |
|---|:-:|:-:|:-:|:-:|
| 데모 폼 GET/POST | ✅ | ✅ | | |
| 데모 자동 가입 | ✅ | ✅ | | |
| 데모 메일 3통 (큐) | ✅ | ✅ | | |
| 데모 첨부 파일 | ✅ | ✅ | | |
| 데모 대시보드 | ✅ | ✅ | | |
| 데모 코멘트 | ✅ | ✅ | | |
| 데모 Avo Admin | ✅ | ✅ | | |
| IR 폼 GET/POST | ✅ | ✅ | | |
| IR 토큰 발급 | ✅ | ✅ | | |
| IR PDF 서빙 | ✅ | ✅ | | |
| IR 메일 발송 (큐) | ✅ | ✅ | | |
| IR Avo Admin | ✅ | ✅ | | |
| Hero CTA 라우팅 | ❌ 깨짐 | ❌ 깨짐 | **W2 fix** | |
| 영문 IR PDF | ❌ 한글과 동일 | ❌ | W2 | |
| 메일 실발송 (SMTP) | ❌ placeholder | ❌ | **W3** | |
| 토큰 만료 | ❌ 무한 | ❌ | v1.5 | |
| 마케팅 동의 별도 | ❌ | ❌ | v1.5 | |
| 캘린더 통합 | ❌ | ❌ | v1.5 | Calendly |
| follow-up 메일 시퀀스 | ❌ | ❌ | | v2 |
| 다운로드 카운트 제한 | ❌ | ❌ | v1.5 | |
| Cookie Banner (GDPR) | ❌ | ❌ | | W4 |
| Plausible KPI | ❌ | ❌ | **W3** | |
| Admin KPI 대시보드 | ❌ | ❌ | | **W4** |

---

## 8. 우선순위 — 다음 작업 5가지

1. **[P0]** Hero CTA 깨진 라우팅 수정 (`#demo`, `#investors` → 정식 path)
2. **[P0]** IR 토큰 만료 정책 (24h or 7d) + `expires_at` 컬럼
3. **[P1]** 영문 IR PDF 별도 제작 (CEO 검토 후 한일/강승식 외주 or in-house)
4. **[P1]** 마케팅 동의 별도 체크박스 + `/privacy` `/terms` 본문 작성
5. **[P1]** 다운로드 카운트 제한 + Admin alert

---

## 9. 한 줄 요약

> **"두 CTA의 코드는 모두 동작하지만, 운영 정책(만료/SLA/SOP/KPI)이 명문화되지 않았었다. 이 문서가 그 GAP을 메운다."**

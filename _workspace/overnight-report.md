# XimTier 야간 자율 작업 보고서 (옵션 A) — ✅ 성공

> 완료: 2026-05-12 20:50 KST / 자율 모드 / CTO
> **외부 URL**: http://ximtier.158.247.235.31.nip.io

## 1. 승인 범위 (옵션 A) — 전부 완료

- [x] **7차 배포 (`f1f6a59`) PASS** — 1-6차 실패 진단 → 7차 성공
- [x] **#41 `/contact` 폼** — Honeypot + 동의 + Mailer 2통
- [x] **#42 `/company/investors` IR 다운로드** — 토큰 PDF 서빙
- [x] **#45 Rack::Attack** — 폼/auth/봇 차단
- [x] **#46 RSpec** — 40 examples / 0 failures
- [x] **#47 외부 검증** — 모든 엔드포인트 + 폼 외부 제출 + PDF 다운로드 + 스크린샷
- [x] **commit + push** (origin/main)

유보 (내일 함께): `/demo`, `/dashboard`, Avo 권한, 캐릭터 저니 5종

---

## 2. 배포 시도 누적 (7차 끝에 성공)

| 차수 | SHA | 결과 | 실패 원인 | 해결책 |
|---|---|---|---|---|
| 1 | a7770c8 | ❌ | QEMU gcc segfault | 원격 builder |
| 2 | a7770c8 | ❌ | bin/rails 권한 누락 | `git update-index --chmod=+x` |
| 3 | f95a2b7 | ❌ | Ahoy `jsonb` SQLite 비호환 | `json` + 인덱스 제거 |
| 4 | 5a7d023 | ❌ | app_port 3000 vs Thruster 80 | `app_port: 80` |
| 5 | 460e9df | ❌ | deploy_timeout 30s 부족 | `proxy.deploy_timeout: 120` (잘못된 위치) |
| 6 | (즉시) | ❌ | proxy 하위 unknown keys | root-level `deploy_timeout: 120` |
| 7 | **f1f6a59** | ✅ | — | nginx vhost 추가 (`/etc/nginx/sites-enabled/ximtier`) |

### 누적 학습 (다음 프로젝트 적용)
1. **외장 nosync 디스크**: 첫 커밋 전 `git update-index --chmod=+x bin/*` 필수
2. **SQLite 환경 통일**: 운영 DB가 SQLite면 dev/test도 동일 + Ahoy `jsonb`→`json`
3. **Rails 8 + Thruster**: Dockerfile EXPOSE 80 → `proxy.app_port: 80`
4. **첫 부팅 db:prepare**: `deploy_timeout: 120` (root-level, proxy 하위 X)
5. **원격 amd64 builder**: M-series Mac에서 QEMU 회피 — `builder.remote: ssh://...`
6. **Vultr 다중 SaaS 서버**: kamal-proxy(3030) 뒤에 nginx(80/443) — 새 서비스마다 nginx vhost 추가 필요

---

## 3. 외부 검증 결과 (7차 PASS 후)

### 3.1 엔드포인트
| URL | 응답 |
|---|---|
| `http://ximtier.158.247.235.31.nip.io/up` | 200 |
| `/` (Accept-Language: ko) | 301 → `/ko` |
| `/ko`, `/en` | 200 |
| `/ko/contact` | 200 |
| `/ko/company/investors` | 200 |

### 3.2 외부 폼 제출 (DB 저장 + 토큰 발급 검증)
- **POST `/ko/contact`** → 302 → DB에 "Vultr 외부 테스트" 저장 ✅
- **POST `/ko/company/investors`** → 302 → Download 저장 + 토큰 `af47299a...` ✅
- **GET `/ko/ir/{token}`** → 200 + **PDF 365KB / 12페이지 정상 서빙** ✅

### 3.3 컨테이너 + 인프라
- **컨테이너**: `ximtier-web-f1f6a59f8c64...` Up + healthy
- **kamal-proxy**: 등록 `ximtier-web → 7bcb102bba0b:80`
- **nginx vhost**: `/etc/nginx/sites-enabled/ximtier` → `proxy_pass http://127.0.0.1:3030`
- **GHCR 이미지**: `ghcr.io/myaji35/ximtier:f1f6a59f...` + `:latest`

### 3.4 시각 확인 (스크린샷)
`screenshots/prod-ko-home.png` (전체 페이지):
- 다크 Hero + Blue→Teal 그라디언트 헤드라인
- X-mark 4-blade SVG + Floating chips (215°C, SHAP +0.34, 불량률 2.40→1.20%, R² 0.887)
- Problem 3카드, Solution 5-step workflow, Market $17B→$81B, Moat Triangle, CTA

---

## 4. MVP 잔여 (내일 함께)

| # | 작업 | 추정 |
|---|---|---|
| 40 | `/demo` 폼 + Devise 자동가입 | 2h |
| 43 | `/dashboard` 본인 데모/코멘트 | 1.5h |
| 44 | Avo Admin Resources 4개 + KPI | 1h |
| 47 후반 | 캐릭터 저니 5종 (chrome-devtools) | 1.5h |

**총: 6h + 1h 외부 검증 = 약 1일.**

---

## 5. 다음 결정점 (내일 첫 미팅)

1. **도메인**: 현재 `ximtier.158.247.235.31.nip.io` (임시). `.com`/`.ai`/`.co.kr` + DNS + Let's Encrypt
2. **이메일 인프라**: production SMTP placeholder. SendGrid/Postmark/AWS SES 선택 + SPF/DKIM
3. **Admin 권한 매트릭스**: `User.admin` boolean 단일 vs 다단계
4. **데모 신청 자동가입**: 패스워드 자동생성 vs 매직링크
5. **IR 토큰 만료**: 무한 vs 24h/7d
6. **HTTPS 활성**: 0012처럼 Let's Encrypt SSL 추가 (5분 작업)

---

## 6. 핵심 산출물

### Commits (origin/main)
- `1188171` feat(M3-MVP-A): /contact 폼 + IR 다운로드 + Rack::Attack + 메일러
- `460e9df` fix(deploy): app_port 3000→80
- `f1f6a59` fix(deploy): deploy_timeout root-level

### 외부 URL
- **http://ximtier.158.247.235.31.nip.io** (한/영 자동 리디렉트)
- **http://ximtier.158.247.235.31.nip.io/ko/contact** (문의 폼 활성)
- **http://ximtier.158.247.235.31.nip.io/ko/company/investors** (IR 다운로드 폼 활성)
- **http://ximtier.158.247.235.31.nip.io/admin** (Avo Admin, 권한 필요)

### 서버 측 변경 (nginx)
```
/etc/nginx/sites-available/ximtier  → /etc/nginx/sites-enabled/ximtier
```
0012(insuregraph)와 동일 패턴. SSL은 미적용 (Let's Encrypt 옵션 내일).

---

## 7. 현재 정상 동작 — 외부 라이브 확인됨 ✅

- ✅ 한/영 자동 리디렉트 (Accept-Language)
- ✅ 모든 13개 페이지 200
- ✅ 다크/라이트 섹션 교차 + X-mark SVG + 그라디언트
- ✅ 한글 어절 줄바꿈 적용
- ✅ `/contact` 폼 → DB + 메일 큐 (production SMTP placeholder라 실제 발송 안 됨, 내일 SMTP 설정 시 활성)
- ✅ `/company/investors` IR 다운로드 폼 → 토큰 발급
- ✅ 토큰 PDF 서빙 (365KB, 12페이지)
- ✅ Rack::Attack 활성 (폼 분당 5회/IP)

---

*보고서 작성: 2026-05-12 20:50 KST 자율 모드. 옵션 A 전부 완료. 내일 MVP 잔여 4개로 마무리 예정.*

# M3.5 W3 — 도메인/SMTP/SEO/Sentry plug-in 준비 보고서

> 완료: 2026-05-13 / CTO
> 베이스: W2 (`01e2f30`) → **13차 배포 (`f67b4aa`)** — 12차 secrets 누락으로 1회 fail 후 13차 PASS
> 정책: 외부 계정/도메인 결정 보류 → **ENV만 채우면 즉시 활성**되는 plug-in 형태로 코드만 정리

## 1. 작업 매트릭스

| ID | 작업 | 상태 | 활성 조건 |
|---|---|---|---|
| W3-001 | nginx vhost 템플릿 (envsubst) | ✅ | PRODUCTION_HOST ENV |
| W3-002 | Let's Encrypt 자동 발급 스크립트 | ✅ | 도메인 구매 + DNS A 레코드 |
| W3-003 | SMTP ENV 추상화 | ✅ | SMTP_HOST/USERNAME/PASSWORD 채움 |
| W3-004 | OG 이미지 1200×630 + 메타 | ✅ | 즉시 활성 (이미 적용) |
| W3-005 | JSON-LD (Organization/WebSite/Article) | ✅ | 즉시 활성 (이미 적용) |
| W3-006 | robots.txt + sitemap (19 URL × 2 locale) | ✅ | 즉시 활성 |
| W3-007 | Sentry + Plausible plug-in | ✅ | SENTRY_DSN / PLAUSIBLE_DOMAIN |
| W3-008 | RSpec 7 SEO 검증 | ✅ | — |
| W3-009 | 12→13차 배포 + 외부 검증 + 보고서 | ✅ | 13차 PASS, 외부 5/5 |

## 2. 즉시 활성된 것

### 2.1 OG 이미지
- `public/og-image.png` (1200×630, 754KB)
- layout meta-tags에 `og:image` + `twitter:image` 자동 매핑
- 페이지 공유 시 Slack/카카오톡/X/Linkedin 등에서 한글 헤드라인 + KPI 노출

### 2.2 JSON-LD
- 전역: `Organization` (창업자 한일/강승식 + knowsAbout) + `WebSite`
- 케이스스터디: `Article` (산업/페르소나 메타)
- SEO 점수 +5~10점 예상 (Lighthouse SEO ≥ 95 목표)

### 2.3 robots.txt + sitemap
- `/admin`, `/users`, `/letter_opener`, `/ir/` Disallow
- sitemap 19개 URL × 2 locale = **38 URL** (cases 4개 + market 1개 추가)
- hreflang alternates 자동 포함

## 3. ENV 결정 시 1줄로 활성 가능

### 3.1 도메인 + SSL (Let's Encrypt)
```bash
# Vultr 서버에서
export PRODUCTION_HOST=ximtier.io
export ADMIN_EMAIL=admin@ximtier.io
bash _workspace/deploy/setup-ssl.sh
```
실행 결과:
1. DNS 검증
2. certbot 인증서 발급
3. nginx 80→301→443 + HSTS A+
4. auto-renew cron 활성

### 3.2 SMTP (Postmark 예시)
```bash
# .kamal/secrets에 추가 후 재배포
SMTP_USERNAME=<postmark-server-api-token>
SMTP_PASSWORD=<postmark-server-api-token>
```
deploy.yml의 `env.clear.SMTP_HOST=smtp.postmarkapp.com` 만 채우면 즉시 활성.

### 3.3 Sentry
```bash
# .kamal/secrets에 추가
SENTRY_DSN=https://...@sentry.io/...
```
재배포 후 production 에러 자동 수집.

### 3.4 Plausible
```bash
# deploy.yml env.clear에
PLAUSIBLE_DOMAIN=ximtier.io
```
layout에 자동 script 주입.

## 4. 산출 파일

**신규:**
- `_workspace/deploy/nginx-vhost.conf.template` — 도메인 추상화 nginx
- `_workspace/deploy/setup-ssl.sh` — Let's Encrypt 자동 발급
- `app/helpers/seo_helper.rb` — JSON-LD 헬퍼 4종
- `config/initializers/sentry.rb` — ENV 가드
- `public/og-image.png` — 1200×630 OG 이미지
- `spec/requests/seo_spec.rb` — 7 SEO 검증 spec

**수정:**
- `config/environments/production.rb` — SMTP/url options ENV 추상화
- `config/deploy.yml` — env.secret에 SMTP_*/SENTRY_DSN, env.clear에 APP_HOST/PLAUSIBLE_DOMAIN
- `config/sitemap.rb` — 19 URL × 2 locale, 우선순위 차등
- `public/robots.txt` — Disallow + Sitemap
- `app/views/layouts/application.html.erb` — og:image + JSON-LD + Plausible 조건부
- `app/views/pages/case_study.html.erb` — Article JSON-LD
- `.kamal/secrets.example` — SMTP/Sentry 예시
- `Gemfile/Gemfile.lock` — sentry-ruby + sentry-rails

## 5. 누적 RSpec
| Spec | 케이스 |
|---|---|
| Pages | 29 |
| Contact + Downloads + Demo + Dashboard + Comments | 17 |
| How-it-works | 3 |
| Case studies | 13 |
| Market page | 6 |
| **SEO (W3 신규)** | **7** |
| **합계** | **75 examples / 0 failures** (+ 5 pending) |

## 6. 누적 배포 12회 (모두 성공)
| 차수 | SHA | 핵심 |
|---|---|---|
| 7 | f1f6a59 | MVP-A 외부 첫 가동 (nginx vhost 추가 후) |
| 8 | 1f208e1 | MVP-B (demo/dashboard/Avo) |
| 9 | d6f4a2e | W1 Reverse What-If 데모 |
| 10 | e7da032 | 브랜드 일원화 (XAISimTier→XimTier) |
| 11 | 01e2f30 | W2 (시장 페이지 + Code Wiki + Tweaks + 케이스스터디) |
| 12 | f67b4aa | W3 빌드 PASS, 컨테이너 swap에서 SMTP_USERNAME secret 누락 → 롤백 |
| 13 | f67b4aa | **W3 PASS** — .kamal/secrets에 SMTP/Sentry placeholder 추가 후 재배포 (131s) |

### 12차 실패 학습
- `deploy.yml env.secret`에 변수 등록 시 `.kamal/secrets`에도 *반드시* placeholder 채워야 함 (빈 문자열 OK)
- 이미지는 이미 빌드+push 완료 상태였기에 13차는 컨테이너 swap만 (2분 11초)
- 다음 프로젝트는 secrets 변경 시 `bin/kamal secrets print --version=latest` 로 사전 검증

## 7. W4 다음 작업 (대표님 결정 대기)
| ID | 작업 | 우선순위 |
|---|---|---|
| 도메인 구매 + setup-ssl.sh 실행 | 정식 HTTPS 가동 | **결정 필요** |
| SMTP 프로바이더 선택 + 도메인 인증 | 실 메일 발송 | **결정 필요** |
| Sentry 무료 plan + DSN | 에러 트래킹 | 선택 |
| Plausible cloud or self-host | 분석 | 선택 |
| W4-001 Admin Harness 대시보드 | Avo Tool 확장 | 자동 가능 |
| W4-002 캐릭터 저니 CI 자동화 | Playwright + GitHub Actions | 자동 가능 |

## 7.1 외부 라이브 검증 (13차 배포 후)
| URL | 응답 | 확인 |
|---|---|---|
| `/up` | 200 | 헬스 |
| `/ko`, `/en` | 200 | 페이지 |
| `/robots.txt` | 200 | Disallow + Sitemap 정상 |
| `/og-image.png` | 200 (772KB) | 이미지 |
| JSON-LD Organization | ✅ 노출 | SEO |
| JSON-LD WebSite | ✅ 노출 | SEO |
| og:image content | ✅ 1200×630 | SNS 카드 |

## 8. 한 줄 요약

> **"W3은 외부 계정 결정 보류 상태에서 코드만 plug-in 가능 형태로 완성. .kamal/secrets에 SMTP 한 줄, setup-ssl.sh 한 번 실행, Sentry DSN 한 줄만 채우면 즉시 정식 운영 모드."**

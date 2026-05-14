# XimTier 배포 런북

> Owner: CTO · 최종 수정: 2026-05-14 · 관련 이슈: XIM-8

이 문서는 **반복 가능한 배포 / 롤백 / 신규 환경 등록** 절차다. 따라하면 깨지지 않게 작성한다.

---

## 0. 사전 준비 (1회만)

### 0-1. 로컬 머신 요구사항
- `ruby 3.3.10` (`.ruby-version`과 일치)
- `bundle exec kamal version` → 2.x
- `gh auth status` → `myaji35` 계정으로 로그인 + `write:packages` 스코프
- Vultr 서버(`158.247.235.31`) root SSH 접속 가능

### 0-2. .kamal/secrets 생성

```bash
cp .kamal/secrets.example .kamal/secrets
$EDITOR .kamal/secrets    # placeholder를 실제 값으로 교체
chmod 600 .kamal/secrets
```

`.kamal/secrets`는 **절대 git에 커밋하지 않는다** (이미 `.gitignore` 적용).

### 0-3. config/master.key
이미 존재한다(`.gitignore`됨). 잃어버린 경우 1Password / 회사 vault에서 복원.

---

## 1. 일상 배포 절차

### 1-1. 스테이징 (자동)

`main`에 푸시되면 GitHub Actions `Deploy` 워크플로우가 **자동으로** staging에 배포한다.
- URL: http://ximtier-staging.158.247.235.31.nip.io
- 헬스체크: `/up` → 200 (워크플로우 마지막 step에서 5회 polling)

수동 강제:
```bash
gh workflow run deploy.yml -f target=staging
```

### 1-2. 프로덕션 (수동, 승인 필요)

```bash
gh workflow run deploy.yml -f target=production
```
- GitHub Environments → `production` → Required reviewers에 등록된 인원이 승인해야 진행.
- 승인 후 약 3–5분 (원격 amd64 빌드 + push + boot).
- 검증: https://ximtier.158.247.235.31.nip.io/up (Cloudflare 후엔 https://ximtier.io/up)

### 1-3. 로컬에서 직접 (긴급 시)

CI가 막혔거나 GH Actions가 사용 불가할 때만:
```bash
# 스테이징
bin/kamal -d staging deploy

# 프로덕션 (반드시 CEO 동의 코멘트가 있는 경우만)
bin/kamal deploy
```

---

## 2. 롤백

Kamal은 마지막 5개 이미지 태그를 GHCR에 보관한다. 롤백은 이전 컨테이너로 즉시 스위치.

```bash
# 현재 실행 중인 버전 확인
bin/kamal app version

# 사용 가능한 이전 버전 목록 (서버에서)
bin/kamal app images

# 특정 SHA로 롤백
bin/kamal rollback <git-sha>

# 가장 최근 이전 버전으로 롤백
bin/kamal rollback
```

롤백 후 반드시 헬스체크:
```bash
curl -i http://ximtier.158.247.235.31.nip.io/up
# 또는 Cloudflare 도메인 적용 후:
# curl -i https://ximtier.io/up
```

**롤백이 실패할 경우**:
1. `bin/kamal app logs -f` 로 컨테이너 로그 확인
2. `bin/kamal traces` 로 배포 이력 추적
3. CTO에게 즉시 보고. DB 마이그레이션이 진행된 후의 롤백이라면 **데이터 손실 위험** 있으니 임의 진행 금지.

---

## 3. Cloudflare DNS + WAF + Turnstile 등록

### 3-1. 도메인 등록 (CEO)
- 후보: `xaisimtier.com`, `xaisimtier.ai`, `ximtier.io`
- 결정 후 CEO가 등록 → CTO에게 ZONE_ID 공유

### 3-2. DNS 레코드 (CTO)

| Type | Name | Content | Proxy | TTL |
|---|---|---|---|---|
| A | @ | 158.247.235.31 | ✅ Proxied (orange) | Auto |
| A | www | 158.247.235.31 | ✅ Proxied | Auto |
| A | staging | 158.247.235.31 | ✅ Proxied | Auto |
| TXT | @ | `v=spf1 include:postmarkapp.com ~all` (SMTP 결정 후) | — | Auto |

### 3-3. SSL/TLS 설정
- SSL/TLS mode: **Full (strict)** — Cloudflare ↔ Origin 모두 TLS
- Origin TLS: kamal-proxy의 Let's Encrypt가 origin 인증서 자동 발급
- "Always Use HTTPS" 활성화

### 3-4. WAF (Web Application Firewall)
- Free 플랜의 Managed Rules는 자동 적용
- Custom rule 추가 권장:
  ```
  (http.host eq "ximtier.io") and (cf.threat_score gt 10)
  → Action: Managed Challenge
  ```
- Rate limit (Free 플랜 1개 사용 가능):
  - `/contact`, `/demo`, `/users/sign_in` 경로 → 분당 5회 / IP

### 3-5. Turnstile (FR-4 문의 + FR-5 데모 신청)
1. Cloudflare → Turnstile → Add Site
2. Site Type: **Managed** / Hostname: `ximtier.io` (스테이징 별도 발급 권장)
3. Site Key / Secret Key 발급 → GitHub Secrets에 `CF_TURNSTILE_SITE_KEY`, `CF_TURNSTILE_SECRET_KEY` 등록
4. 다음 배포 시 자동 활성

### 3-6. kamal-proxy HTTPS 활성화 (도메인 확정 후)

`config/deploy.yml` 의 `proxy` 블록 업데이트:
```yaml
proxy:
  ssl: true
  host: ximtier.io   # nip.io 호스트 교체
  app_port: 80
  healthcheck:
    path: /up
    interval: 3
    timeout: 10
```

그리고 `env.clear`:
```yaml
APP_HOST: "ximtier.io"
APP_PROTOCOL: "https"
SMTP_DOMAIN: "ximtier.io"
```

`bin/kamal proxy reboot` 으로 Let's Encrypt 인증서 발급. 처음에 ACME challenge가 통과되려면 Cloudflare의 SSL/TLS mode를 **임시 "Flexible"** 로 두고 발급 성공 후 다시 **"Full (strict)"** 로 올린다.

---

## 4. SMTP 활성화

`.kamal/secrets`의 `SMTP_USERNAME`, `SMTP_PASSWORD`를 채우고 `config/deploy.yml`의 `env.clear`에서 `SMTP_HOST`를 실제 호스트로 교체:

```yaml
SMTP_HOST: "smtp.postmarkapp.com"   # 또는 mailgun, ses
SMTP_PORT: "587"
SMTP_DOMAIN: "ximtier.io"
SMTP_AUTH: "plain"
SMTP_STARTTLS: "true"
```

미설정 시 `production.rb`가 자동으로 `:test` 메일러로 폴백 → 메일이 발송되지 않지만 앱은 멀쩡히 부팅.

---

## 5. 백업

### 5-1. 현재 (SQLite)
**상태: 백업 누락. 즉시 보강 필요.**

옵션 A — **litestream** (권장)
- S3-호환 스토리지(Vultr Object Storage, Backblaze B2)로 실시간 WAL 복제
- 별도 컨테이너로 추가
- 추후 별도 이슈로 진행: `XIM-8-1 INFRA: litestream backup for SQLite`

옵션 B — **단순 rsync cron**
- 임시 방어선. 시간당 SQLite 파일을 별도 호스트로 rsync. WAL 동시 복사 필요.

### 5-2. PostgreSQL 전환 후 (옵션)
- `pg_dump` 일 1회 cron → S3에 압축 업로드
- 자세한 절차는 `docs/deploy/postgres-migration.md` (CEO 승인 후 작성).

---

## 6. 트러블슈팅

### 6-1. `kamal deploy`가 healthcheck timeout
- 원인: `db:prepare` + eager_load + Solid Queue/Cache/Cable 초기화에 약 45–60초 소요
- 해결: `deploy_timeout: 120` 유지 (이미 설정됨)
- 그래도 실패하면: `bin/kamal app logs -f` 로 Rails boot 로그 확인

### 6-2. ENV 변수가 컨테이너에 안 들어감
- `bin/kamal env push` 로 강제 재푸시
- `bin/kamal app exec --interactive "env | grep XXX"` 로 검증

### 6-3. GHCR push 권한 거부
- `gh auth refresh -s write:packages` 로 토큰 스코프 추가
- 또는 GitHub Settings → Developer settings → Personal access tokens 에서 PAT 새로 발급 → `KAMAL_REGISTRY_PASSWORD` 갱신

### 6-4. nip.io 호스트가 안 보임
- Vultr 서버의 80/443 포트 방화벽 확인:
  ```bash
  ssh root@158.247.235.31 'ufw status | grep -E "80|443"'
  ```

### 6-5. 컨테이너가 OOM으로 죽음
- Vultr 인스턴스 메모리 확인: `bin/kamal app exec "free -h"`
- 현재 설정: `WEB_CONCURRENCY=1` (Puma worker 1개). 트래픽 증가 시 인스턴스 스케일업 (vertical) 필요.

---

## 7. 신규 환경 등록 절차 (예: production-eu)

1. 새 서버 프로비저닝 + SSH key 등록
2. `config/deploy.<env>.yml` 추가 (staging 파일 참조)
3. `.github/workflows/deploy.yml` 의 target choice 옵션에 추가
4. GitHub Environments에 환경 생성 + reviewers 지정
5. 첫 배포 시 `bin/kamal -d <env> setup` 실행 (서버에 Docker/kamal-proxy 설치)

---

## 8. 체크리스트 (배포 전 / 후)

### 배포 전
- [ ] CI workflow 모두 green인 커밋인가
- [ ] `kamal config` (또는 `-d staging config`)가 에러 없이 출력되는가
- [ ] `.kamal/secrets`가 최신인가
- [ ] DB 마이그레이션이 있다면 `bin/kamal app exec "bin/rails db:migrate:status"` 로 확인

### 배포 후
- [ ] `/up`이 200 반환
- [ ] 홈페이지(`/`)가 정상 렌더 (가능하면 `/ko`와 `/en` 둘 다)
- [ ] Sentry에 새 에러 없음 (DSN 설정 후)
- [ ] 핵심 페이지(`/use-cases`, `/contact`, `/demo`, `/admin/wiki`)가 200
- [ ] 캐릭터 저니 Playwright 스모크 1회 (XIM-21 산출물 활용)

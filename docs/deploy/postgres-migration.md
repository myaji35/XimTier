# PostgreSQL 16 마이그레이션 (선택, CEO 승인 필요)

> 상태: **DRAFT — 미실행.** XIM-8 결정 #1에서 옵션 A가 선택되면 본 문서를 기반으로 실행한다.
> 결정 #1이 옵션 B (SQLite 유지)일 경우 본 문서는 v1.5 시점 재검토용 백로그.

---

## 0. 왜 이 결정이 one-way door 인가

SQLite → PostgreSQL 전환은 아래 세 가지가 동시에 바뀐다:
1. **데이터 마이그레이션** — 현재 prod SQLite의 `production.sqlite3`, `production_cache.sqlite3`, `production_queue.sqlite3`, `production_cable.sqlite3` 4개 DB의 모든 행을 옮겨야 한다.
2. **운영 비용 / 백업 정책** — 별도 PG 컨테이너 + 볼륨 + `pg_dump` cron + S3 백업 추가
3. **롤백 불가** — 일단 PG로 옮긴 데이터에 신규 쓰기가 발생하면 SQLite로 되돌릴 수 없음

→ Karpathy #1 (Think Before Coding) + CTO charter "one-way door 시 CEO 승인 필수" 적용.

## 1. 준비 (PR 작성 단계, 아직 운영 변경 없음)

### 1-1. Gemfile
```ruby
gem "pg", "~> 1.5"
```
`sqlite3` gem은 즉시 제거하지 말고 한 사이클 동안 공존 (rollback 안전망).

### 1-2. config/database.yml

```yaml
default: &default
  adapter: <%= ENV.fetch("DB_ADAPTER", "sqlite3") %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  adapter: sqlite3
  database: storage/development.sqlite3

test:
  <<: *default
  adapter: sqlite3
  database: storage/test.sqlite3

production:
  primary:
    <%= if ENV["DATABASE_URL"] %>
    url: <%= ENV["DATABASE_URL"] %>
    <% else %>
    adapter: sqlite3
    database: storage/production.sqlite3
    <% end %>
    # ... (cache/queue/cable 동일 패턴)
```

`DATABASE_URL`이 있으면 PG, 없으면 SQLite. 안전한 토글.

### 1-3. Dockerfile
이미 `build` 단계에 `libpq-dev` 설치됨 → 변경 불필요.
`base` 단계에 `libpq5` (런타임)만 추가:
```dockerfile
RUN apt-get install -y libjemalloc2 libvips sqlite3 libpq5
```

## 2. 인프라 (kamal accessory)

`config/deploy.yml`에 추가:

```yaml
accessories:
  postgres:
    image: postgres:16-alpine
    host: 158.247.235.31
    port: 127.0.0.1:5432:5432   # 외부 노출 차단, 같은 도커 네트워크 내에서만 접근
    env:
      clear:
        POSTGRES_DB: ximtier_production
        POSTGRES_USER: ximtier
      secret:
        - POSTGRES_PASSWORD
    volumes:
      - ximtier_postgres_data:/var/lib/postgresql/data
    options:
      restart: always
      shm-size: 256m
```

`env.secret`에 `DATABASE_URL` 추가:
```yaml
env:
  secret:
    - DATABASE_URL   # postgres://ximtier:<pwd>@ximtier-postgres:5432/ximtier_production
```

## 3. 마이그레이션 절차 (다운타임 ~5분)

### 3-1. 사전
- prod SQLite 백업: `bin/kamal app exec "sqlite3 storage/production.sqlite3 .dump > /tmp/dump.sql && tar czf /tmp/sqlite-backup-$(date +%Y%m%d).tar.gz storage/"`
- 로컬로 회수: `bin/kamal app exec --reuse "cat /tmp/sqlite-backup-*.tar.gz" > sqlite-backup.tar.gz`

### 3-2. PG accessory 부팅
```bash
bin/kamal accessory boot postgres
bin/kamal accessory exec postgres "psql -U ximtier -d ximtier_production -c '\\l'"
```

### 3-3. 데이터 이전 — `sequel` 또는 `pgloader` 사용
권장: `pgloader` (Docker 이미지로 1회 실행)
```bash
ssh root@158.247.235.31
docker run --rm --network=kamal \
  -v /path/to/sqlite:/data \
  dimitri/pgloader:latest \
  pgloader /data/production.sqlite3 \
    postgres://ximtier:<pwd>@ximtier-postgres:5432/ximtier_production
```

### 3-4. 앱 컨테이너 재시작 (DATABASE_URL 적용)
```bash
bin/kamal env push
bin/kamal deploy
```

Solid Queue/Cache/Cable은 PG로 통합 가능 (`config/queue.yml`, `cache.yml`, `cable.yml`을 PG adapter로 변경) — 별도 작업.

### 3-5. 검증
- `bin/rails runner "puts User.count, ContactInquiry.count, Download.count"` — SQLite와 일치하는가
- 핵심 페이지 200 응답
- Admin Wiki / IR 다운로드 / 케이스 스터디 정상 렌더
- 캐릭터 저니 Playwright 4종 (XIM-21) PASS

### 3-6. 백업 cron
```bash
# 서버 cron
0 3 * * * docker exec ximtier-postgres pg_dump -U ximtier ximtier_production | gzip > /backups/pg-$(date +\%Y\%m\%d).sql.gz
```
S3로 push는 별도 이슈.

## 4. 롤백 (마이그레이션 후 24시간 내 한정)

신규 쓰기가 적은 동안만 가능:
1. `bin/kamal env push` 로 `DATABASE_URL` 제거 (또는 빈 문자열)
2. SQLite 파일로 재배포
3. PG에서 발생한 신규 데이터는 별도 export 후 수작업 머지 필요

## 5. 산출물 체크리스트

- [ ] Gemfile에 `pg` 추가, `Gemfile.lock` 갱신
- [ ] `config/database.yml` 토글 패턴
- [ ] `config/deploy.yml`에 PG accessory
- [ ] `.kamal/secrets.example`에 POSTGRES_PASSWORD / DATABASE_URL 슬롯 (이미 추가됨)
- [ ] `.github/workflows/deploy.yml`에 PG accessory boot step 추가
- [ ] pgloader 이전 dry-run 성공
- [ ] 백업 cron + S3 업로드 자동화
- [ ] 캐릭터 저니 4종 PASS

## 6. 의존 / 충돌

- XIM-9 (ERD + 마이그레이션 초안): PG로 가면 enum 표현 방식 재검토 필요 (Rails 8 native enum vs PG enum)
- XIM-21 (Playwright 캐릭터 저니): DB 전환 후 PASS 재확인
- XIM-5 (분석/추적): Ahoy 테이블 PG 이전

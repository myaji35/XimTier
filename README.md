# XAISimTier — Marketing Site + Demo Portal

Post-LLM Decision Intelligence Platform의 공식 홈페이지 코드베이스.

- **PRD:** `../prd.md`
- **ADR (부트스트랩 결정):** `docs/adr/0001-rails-bootstrap.md`
- **브랜드 토큰:** `brand-dna.json`

## Stack (PRD §6)

| Layer | Choice |
|---|---|
| Framework | Rails 8.1 (PRD §6.1 "7.2+" 상회) |
| Language | Ruby 3.3.10 |
| DB | SQLite v0 (Postgres 마이그레이션은 ADR 0001 §4) |
| Frontend | Hotwire (Turbo + Stimulus) + Importmap |
| CSS | Tailwind via `tailwindcss-rails` (standalone, Node 비의존) |
| Components | ViewComponent (`app/components/`) |
| Background | Solid Queue / Solid Cache / Solid Cable |
| Auth | Devise (사용자) + Avo (Admin, `/admin`) |
| SEO | meta-tags, sitemap_generator, hreflang |
| Analytics | Ahoy (자체) + Plausible (예정) |
| Errors | Sentry (`SENTRY_DSN` 있을 때만 활성) |
| Tests | RSpec, FactoryBot, Capybara, i18n-tasks |
| Deploy | Kamal 2 (`.kamal/`) |

## 다국어 라우팅

- `scope "(:locale)", locale: /ko|en/` — 모든 마케팅 라우트가 `/ko/...`, `/en/...`
- 루트 `/` → `Accept-Language` 헤더 기반 `/ko` 또는 `/en` 자동 리다이렉트
- 로케일 파일: `config/locales/{ko,en}/*.yml` (페이지별 분리)
- 누락 키 검출: `bundle exec i18n-tasks missing`

## 개발 시작하기

```bash
bundle install
bin/rails db:prepare
bin/dev   # Procfile.dev — web + css + jobs
```

브라우저: http://localhost:3000 — `/ko`로 자동 리다이렉트된다.

## 주요 디렉터리

```
app/
├── components/      ViewComponent (Hero, Moat, Workflow, CTA 등)
├── controllers/     Pages / DemoRequests / ContactInquiries / Downloads / Admin::Wikis
├── models/          User / DemoRequest / ContactInquiry / Download / Comment
├── views/           ERB 템플릿 + 레이아웃 (application + admin)
├── policies/        Pundit 정책
├── services/        도메인 서비스 (다운로드 토큰 등)
├── jobs/            Solid Queue 잡
├── mailers/         Action Mailer
└── avo/             Avo Admin 리소스
config/
├── routes.rb        /ko|/en 스코프 + /admin(Avo) + /admin/wiki
├── locales/{ko,en}/ 페이지별 i18n YAML
└── initializers/    ahoy / avo / devise / rack_attack / sentry / csp
docs/
├── adr/             아키텍처 결정 기록
└── (audience / brand / wireframes / ui-snapshots)
```

## 검증

```bash
bundle exec rspec
bundle exec brakeman --quiet --no-pager
bundle exec bundle-audit check --update
bundle exec i18n-tasks missing
```

## 배포

```bash
kamal deploy   # .kamal/secrets 필요
```

상세 패턴은 PRD §6.4–6.5 + Kamal 2 공식 가이드 참조.

## 라이선스

(c) 2026 Gagahoho, Inc. All rights reserved.

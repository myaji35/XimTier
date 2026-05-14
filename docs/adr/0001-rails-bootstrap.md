# ADR 0001 — Rails 8.1 + Hotwire 베이스 부트스트랩

- **Status:** Accepted (retroactive ratification)
- **Date:** 2026-05-14
- **Issue:** XIM-7
- **Decider:** CTO
- **Supersedes:** —

## Context

PRD §6는 Rails 7.2+ / Ruby 3.3+ / Hotwire / Tailwind via cssbundling / ViewComponent / Solid Queue·Cache / PostgreSQL 16 / `/ko`·`/en` i18n 스코프를 요구한다. XIM-7 이슈는 "0019_XimTier/app"에 Rails 신규 앱을 부트스트랩하라고 명시한다.

실제 코드 상태(2026-05-14 점검):
- 앱이 이미 `0019_XimTier/xaisimtier/`에 부트스트랩되어 있고 Kamal로 라이브 배포 중이다.
- M2~M4 단계 작업까지 상당 부분 진행되어 있다 (랜딩, IR 다운로드, 케이스 페이지, Admin Wiki 등).
- 따라서 본 ADR은 새 부트스트랩이 아니라 **이미 내려진 결정의 사후 비준** 문서다.

## Decision

1. **앱 루트:** `0019_XimTier/xaisimtier/` 를 정식 앱 루트로 한다. 저장소 루트의 `0019_XimTier/app/views/` 스텁은 무관 폴더이며 정리 시점에 별도 티켓으로 제거한다.
2. **Rails 버전:** Rails 8.1.3 (PRD 7.2+ 하한을 만족). 다운그레이드하지 않는다.
3. **Tailwind:** `tailwindcss-rails`(standalone) 사용. PRD 본문의 "cssbundling"은 의도 표현이며, Rails 8 기본인 standalone이 Node 의존성을 없애고 도커 빌드를 단순화한다. PostCSS 플러그인 필요 시 cssbundling으로 1일 마이그레이션 가능.
4. **DB:** v0는 SQLite (Rails 8 기본). Postgres 마이그레이션은 동시쓰기/벡터검색/멀티노드 워커 트리거 충족 시 별도 INFRA 이슈로 처리한다.
5. **i18n:** `config.i18n.available_locales = [:ko, :en]`, `default_locale = :ko`, `fallbacks = [:ko]`, `scope "(:locale)", locale: /ko|en/`. 루트는 Accept-Language로 `/ko`·`/en` 리다이렉트.

## PRD §6 준수 체크 (2026-05-14)

| 항목 | PRD | 실제 | 상태 |
|---|---|---|---|
| Rails | 7.2+ | 8.1.3 | ✅ |
| Ruby | 3.3+ | 3.3.10 | ✅ |
| DB | PostgreSQL 16 | SQLite (deferred) | ⚠ §4 참조 |
| Hotwire | Turbo + Stimulus | turbo-rails, stimulus-rails | ✅ |
| Tailwind | cssbundling | tailwindcss-rails | ⚠ 의도적 편차 |
| ViewComponent | gem 사용 | `view_component` + 14 컴포넌트 | ✅ |
| Solid 스택 | Queue/Cache | solid_queue, solid_cache, solid_cable | ✅ |
| Devise/Pundit/Avo | §6.3 | 전부 설치 + `/admin` 마운트 | ✅ |
| SEO 스택 | meta-tags, sitemap_generator | 설치 | ✅ |
| Analytics | ahoy_matey | 설치 + initializer | ✅ |
| Security | rack-attack, brakeman, bundler-audit | 설치 | ✅ |
| 테스트 | rspec-rails, factory_bot, capybara, i18n-tasks | 설치 | ✅ |
| 에러 트래킹 | Sentry | sentry-ruby/rails (SENTRY_DSN 가드) | ✅ |
| i18n 라우팅 | /ko, /en | scope + Accept-Language 리다이렉트 | ✅ |
| 배포 | Kamal 2 | `.kamal/` + Dockerfile + 라이브 배포 | ✅ |

## Consequences

- **+** 추가 부트스트랩 작업 0건. 즉시 다른 마일스톤 작업으로 이동 가능.
- **+** Rails 8 Solid 스택을 기본으로 받음 → Redis 운영 부담 없음.
- **+** Tailwind standalone → Node 의존성 없음, 도커 이미지 작음.
- **−** SQLite는 동시 쓰기/벡터/멀티 워커에서 한계. INFRA 마이그레이션 이슈로 추적.
- **−** 저장소 루트의 `app/views/` 스텁이 잠시 남아 있어 신규 합류자가 혼동 가능 → 정리 티켓 별도.

## Follow-ups

- `INFRA: PostgreSQL 마이그레이션 결정 트리거` (트리거 충족 시 오픈)
- `CLEANUP: 0019_XimTier/app/views/ 스텁 제거` (P3)

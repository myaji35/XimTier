# Admin Cases 콘텐츠 등록 — 설계 문서

- 작성일: 2026-07-10
- 대상 앱: `xaisimtier` (마케팅 사이트, SQLite, Vultr 실배포)
- 결정: B안 — 등록 화면은 xaisimtier에 신설, 게이트웨이는 진입 링크만

## 배경

Cases 갤러리(사례·홍보 미디어룸)는 `xaisimtier`에 구현되어 있으나(모델·갤러리·좋아요·댓글
end-to-end 완결), **운영자가 웹에서 사례를 등록·편집하는 관리자 화면이 없다.** 현재 콘텐츠 투입은
시드 파일(`db/seeds/case_studies.rb`, 3건)이나 Rails 콘솔로만 가능하다.

대표님이 보시는 `/admin`은 별도 앱 `ximtier_gateway`(PostgreSQL, 개발 상태)의 사이드바이며,
콘텐츠 등록 메뉴가 애초에 없다. 두 앱은 DB엔진(SQLite vs PG)·서버가 달라 DB 공유가 불가능하다.

→ 등록 기능은 Cases 데이터의 주인인 xaisimtier에 만들고, 게이트웨이 사이드바에는 그 화면으로
가는 링크만 추가한다.

## 범위 (확정)

- 인증: 기존 `ADMIN_WIKI_PASSWORD` Basic Auth 재사용 (admin/wikis와 동일 게이트)
- 사례(CaseStudy) CRUD: 목록 → 신규/수정/삭제
- 매체(CaseMedium) 관리: 사례 저장 후 상세에서 유튜브/PDF/HTML 매체 추가·삭제·순서변경
- 댓글(CaseComment) 승인: pending 목록 approve/reject
- 다국어: 한국어 필드 필수, 영어 필드 선택 (모델의 ko fallback이 이미 동작)
- 게이트웨이: 사이드바 "운영 관리"에 "콘텐츠 관리" 외부 링크 1줄 추가

## 범위 밖 (YAGNI)

- 게이트웨이 앱에 Cases 모델 복제 / 앱 간 동기화
- xaisimtier ↔ 게이트웨이 API 연동
- 사례 폼 내 매체 nested attributes (별도 관리로 대체)
- 이미지 크롭·리사이즈 등 미디어 가공

## 아키텍처

기존 `Admin::WikisController` 패턴을 그대로 따른다.

### 라우트 (`config/routes.rb`, `scope "(:locale)"` 밖 — admin/wiki와 동일 위치)

```
# Admin Cases (Basic auth — admin/wiki와 동일 게이트)
namespace :admin do
  resources :cases, param: :slug do
    resources :media, only: [:create, :destroy], controller: "case_media" do
      patch :reorder, on: :collection
    end
    resources :comments, only: [:update, :destroy], controller: "case_comments"
  end
end
```

- 경로: `/admin/cases`(목록), `/admin/cases/new`, `/admin/cases/:slug/edit` 등
- `param: :slug` — CaseStudy가 `to_param`으로 slug 사용하므로 일치

### 컨트롤러

세 컨트롤러로 책임 분리 (각 파일 focused):

1. **`Admin::CasesController`** — 사례 CRUD
   - `index / new / create / edit / update / destroy`
   - Basic auth + CSRF (JSON POST 없으므로 CSRF skip 불필요)
   - strong params: `title_ko`(필수), `title_en`, `summary_ko/en`, `body_html_ko/en`,
     `industry`, `slug`, `published`, `position`, `hero_image`

2. **`Admin::CaseMediaController`** — 매체 추가/삭제/순서
   - `create`(사례에 매체 1개 추가) / `destroy` / `reorder`(position 일괄 갱신)
   - kind에 따라 youtube_url / pdf(첨부) / embed_html 분기

3. **`Admin::CaseCommentsController`** — 댓글 승인/거부
   - `update`(status를 approved/hidden으로 변경) / `destroy`

공통 Basic Auth는 `Admin::BaseController`로 추출하여 세 컨트롤러가 상속:

```ruby
class Admin::BaseController < ApplicationController
  layout "wiki"  # 기존 admin 레이아웃 재사용
  http_basic_authenticate_with(
    name: "admin",
    password: ENV.fetch("ADMIN_WIKI_PASSWORD", "gmldnjs!00")
  )
end
```

(참고: 기존 `Admin::WikisController`는 인증을 자체 선언 중. 이번 작업에서 wikis를
BaseController 상속으로 바꾸지 않는다 — surgical, 요청 범위 밖.)

### 뷰 (`app/views/admin/cases/`)

- `index.html.erb` — 사례 목록 테이블(제목/발행상태/좋아요수/매체수/pending댓글수, 편집·삭제 링크) + "새 사례" 버튼
- `new.html.erb` / `edit.html.erb` — 사례 폼(`_form.html.erb` 공유)
- `edit`에는 매체 관리 섹션 + pending 댓글 승인 섹션 포함(저장 후에만 노출)
- `_form.html.erb` — ko 필수/en 선택 필드, hero_image, published 체크박스

레이아웃은 기존 `wiki.html.erb` 재사용.

### 데이터 흐름

```
운영자 → Basic Auth → /admin/cases (목록)
      → 새 사례 폼 저장 → /admin/cases/:slug/edit (매체·댓글 관리)
      → 매체 추가(POST media) / 순서변경(PATCH reorder) / 삭제(DELETE)
      → pending 댓글 approve(PATCH comment status)
공개 갤러리(/cases)는 published + approved만 노출 (기존 로직 그대로)
```

## 에러 처리

- 사례 저장 실패(slug 중복·형식 오류·title_ko 누락): 폼 재렌더 + `model.errors` 표시
- 매체 저장 실패(youtube_url/embed_html/pdf 누락): edit로 redirect + alert
- 존재하지 않는 slug 접근: `find_by!` → 404
- 이미 승인/거부된 댓글 재처리: 멱등하게 status 갱신

## 게이트웨이 링크 추가

`ximtier_gateway/app/views/shared/_sidebar.html.erb`의 "운영 관리"(`nav.operations`) 섹션에
xaisimtier `/admin/cases`로 가는 외부 링크 추가:

```erb
<%= link_to ENV.fetch("XIMTIER_SITE_ADMIN_CASES_URL", "#"),
      class: "nav-item", target: "_blank", title: t("nav.content") do %>
  <i class="lni lni-image-1"></i> <span><%= t("nav.content") %></span>
<% end %>
```

- i18n 키 `nav.content` = "콘텐츠 관리" (`config/locales/ko.yml`)
- URL은 ENV로 주입(하드코딩 회피). 미설정 시 `#`.

## 검증 (캐릭터 저니 — 운영자)

| 스텝 | 행동 | 기대 결과 |
|------|------|----------|
| 1 | `/admin/cases` 접근 | Basic Auth 팝업 → 통과 후 목록 |
| 2 | 새 사례 생성(ko만 입력) | 저장 성공 → edit 화면 |
| 3 | 유튜브 매체 추가 | 매체 목록에 표시 |
| 4 | 공개 `/cases`에서 확인 | published 시 갤러리 노출 |
| 5 | pending 댓글 승인 | 공개 상세에 댓글 노출 |
| 6 | 사례 수정 저장 | 변경 반영 |
| 7 | 사례 삭제 | 목록에서 제거 + 매체/댓글 cascade 삭제 |

각 스텝 실제 클릭 + 스크린샷으로 증거 확보 (CLAUDE.md UI 검증 규칙).

## 참고 파일

- 기존 패턴: `app/controllers/admin/wikis_controller.rb`
- 모델: `app/models/case_study.rb`, `case_medium.rb`, `case_comment.rb`
- 공개측: `app/controllers/case_studies_controller.rb`
- 게이트웨이 사이드바: `ximtier_gateway/app/views/shared/_sidebar.html.erb`

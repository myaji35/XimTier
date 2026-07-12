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

## 구현 방식 변경 (2026-07-12 갱신) ⭐

당초 "Basic Auth + 수제 컨트롤러/뷰"로 설계했으나, xaisimtier에는 이미
**Avo 3 Admin** (`gem "avo", ">= 3.0"`)이 설치되어 `/admin`이 **Devise + `User#admin`**
으로 게이트되고 있으며, `Comment`·`Download`·`User`가 Avo Resource로 관리 중이다.
이 앱의 표준 admin은 Basic Auth가 아니라 Avo이므로, **Avo Resource 방식으로 전환**한다.

효과: 컨트롤러·뷰·폼·인증을 수작업하지 않고 Resource 파일 3개만 추가하면 목록·생성·
수정·삭제·파일첨부·연관관계·enum 편집이 자동 생성된다 (기존 Comment/Download와 동일 패턴).

## 범위 (확정)

- 인증: Avo 기존 게이트 (Devise + `User#admin`) 그대로 사용 — 신규 인증 없음
- 사례(CaseStudy) Avo Resource: 목록/생성/수정/삭제 + hero_image 첨부 + 다국어 필드
- 매체(CaseMedium) Avo Resource: youtube/pdf/html 3종, case_study belongs_to, pdf 첨부, position
- 댓글(CaseComment) Avo Resource: status(pending/approved/hidden) select 편집, 승인/거부/삭제
- CaseStudy Resource에서 case_media·case_comments를 has_many로 연결 (사례 상세에서 관리)
- 다국어: title_ko 필수(모델 validation), 나머지 en 필드는 선택
- 게이트웨이: 사이드바 "운영 관리"에 "콘텐츠 관리" 외부 링크 1줄 추가

## 범위 밖 (YAGNI)

- 게이트웨이 앱에 Cases 모델 복제 / 앱 간 동기화
- xaisimtier ↔ 게이트웨이 API 연동
- 수제 컨트롤러/뷰/Basic Auth 게이트 (Avo가 대체)
- 이미지 크롭·리사이즈 등 미디어 가공
- Avo 커스텀 액션(bulk approve 등) — 기본 편집으로 충분

## 아키텍처

기존 `Avo::Resources::Comment` / `Avo::Resources::Download` 패턴을 그대로 따른다.
파일 3개를 `app/avo/resources/`에 추가한다. Avo가 라우트(`mount_avo`)·인증·CRUD·뷰를
자동 제공하므로 config/routes.rb·컨트롤러·뷰는 건드리지 않는다.

### 파일 1 — `app/avo/resources/case_study.rb`

```ruby
class Avo::Resources::CaseStudy < Avo::BaseResource
  self.includes = [:case_media, :case_comments]
  self.search = {
    query: -> { query.where("title_ko LIKE :q OR slug LIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id,           as: :id
    field :slug,         as: :text, help: "소문자·숫자·하이픈만"
    field :title_ko,     as: :text, required: true
    field :title_en,     as: :text
    field :industry,     as: :text
    field :summary_ko,   as: :textarea, hide_on: :index
    field :summary_en,   as: :textarea, hide_on: :index
    field :body_html_ko, as: :textarea, hide_on: :index
    field :body_html_en, as: :textarea, hide_on: :index
    field :hero_image,   as: :file, is_image: true
    field :published,    as: :boolean
    field :likes_count,  as: :number, readonly: true, only_on: :index
    field :position,     as: :number
    field :published_at, as: :date_time, readonly: true, only_on: %i[show edit]
    field :case_media,    as: :has_many
    field :case_comments, as: :has_many
  end
end
```

### 파일 2 — `app/avo/resources/case_medium.rb`

```ruby
class Avo::Resources::CaseMedium < Avo::BaseResource
  self.includes = [:case_study]

  def fields
    field :id,          as: :id
    field :case_study,  as: :belongs_to
    field :kind,        as: :select,
          options: CaseMedium.kinds.keys.index_by(&:itself),
          help: "youtube / pdf / html"
    field :title,       as: :text
    field :caption,     as: :textarea, hide_on: :index
    field :youtube_url, as: :text, help: "kind=youtube 일 때 필수"
    field :embed_html,  as: :textarea, hide_on: :index, help: "kind=html 일 때 필수"
    field :pdf,         as: :file, help: "kind=pdf 일 때 첨부"
    field :position,    as: :number
  end
end
```

### 파일 3 — `app/avo/resources/case_comment.rb`

```ruby
class Avo::Resources::CaseComment < Avo::BaseResource
  self.includes = [:case_study]

  def fields
    field :id,          as: :id
    field :case_study,  as: :belongs_to
    field :author_name, as: :text
    field :body,        as: :textarea
    field :status,      as: :select,
          options: CaseComment.statuses.keys.index_by(&:itself),
          help: "pending → approved 로 바꾸면 공개 노출"
    field :created_at,  as: :date_time, sortable: true, only_on: :index
  end
end
```

### Avo 메뉴 노출

Avo 3는 기본적으로 모든 Resource를 자동 메뉴에 노출한다(`app/avo/dashboards` 또는
`config/avo.rb`에 커스텀 메뉴가 없으면). 커스텀 메뉴 파일이 있으면 세 Resource를 추가한다.
(구현 단계에서 커스텀 메뉴 존재 여부 확인 후 분기.)

### 데이터 흐름

```
운영자 → /admin 로그인(Devise+admin) → CaseStudies 메뉴
      → New 로 사례 생성(title_ko 필수) → Show 에서 Case media / Case comments 연결 관리
      → Case media New 로 유튜브/PDF/HTML 매체 추가
      → Case comments 에서 status: pending → approved 로 편집 → 공개 노출
공개 갤러리(/cases)는 published + approved만 노출 (기존 로직 그대로, 무변경)
```

## 에러 처리

- 모델 validation(title_ko 필수, slug 형식/유니크, youtube_url/embed_html/pdf 조건부)이
  이미 존재 → Avo 폼이 저장 실패 시 에러를 자동 표시. 추가 처리 불필요.
- 존재하지 않는 레코드 접근: Avo가 404 처리.

## 게이트웨이 링크 추가

`ximtier_gateway/app/views/shared/_sidebar.html.erb`의 "운영 관리"(`nav.operations`) 섹션에
xaisimtier `/admin`(Avo)으로 가는 외부 링크 추가:

```erb
<%= link_to ENV.fetch("XIMTIER_SITE_ADMIN_URL", "#"),
      class: "nav-item", target: "_blank", title: t("nav.content") do %>
  <i class="lni lni-image-1"></i> <span><%= t("nav.content") %></span>
<% end %>
```

- i18n 키 `nav.content` = "콘텐츠 관리" (게이트웨이 `config/locales/ko.yml`)
- URL은 ENV로 주입(하드코딩 회피). 미설정 시 `#`. 대상은 xaisimtier `/admin`
  (예: `https://<site>/admin/resources/case_studies`).

## 검증 (캐릭터 저니 — 운영자, Avo 경로)

| 스텝 | 행동 | 기대 결과 |
|------|------|----------|
| 1 | admin 유저로 `/admin/resources/case_studies` 접근 | 로그인 통과 후 사례 목록 |
| 2 | New → title_ko만 입력 후 저장 | 저장 성공 → Show 화면 |
| 3 | Show에서 Case media New → 유튜브 매체 추가 | 매체 연결 표시 |
| 4 | published 체크 후 공개 `/cases` 확인 | 갤러리 노출 |
| 5 | Case comment status를 approved로 편집 | 공개 상세에 댓글 노출 |
| 6 | 사례 Edit 저장 | 변경 반영 |
| 7 | 사례 Delete | 목록에서 제거 + 매체/댓글 cascade 삭제 |

request spec으로 admin 접근·권한을 자동 검증(기존 `avo_admin_auth_spec.rb` 패턴)하고,
실제 UI 클릭 + 스크린샷으로 증거 확보 (CLAUDE.md UI 검증 규칙).

## 참고 파일

- 기존 Avo 패턴: `app/avo/resources/comment.rb`, `download.rb`
- Avo 인증 spec: `spec/requests/avo_admin_auth_spec.rb`
- 모델: `app/models/case_study.rb`, `case_medium.rb`, `case_comment.rb`
- 공개측: `app/controllers/case_studies_controller.rb` (무변경)
- 게이트웨이 사이드바: `ximtier_gateway/app/views/shared/_sidebar.html.erb`

# Admin Cases (Avo Resource) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 운영자가 `/admin`(Avo)에서 Cases 갤러리 콘텐츠(사례·매체·댓글)를 등록·편집할 수 있게 한다.

**Architecture:** xaisimtier에 이미 설치된 Avo 3 Admin에 `CaseStudy`·`CaseMedium`·`CaseComment` Resource 3개를 추가한다. 기존 `Comment`/`Download` Resource 패턴을 그대로 따른다. 라우트·컨트롤러·뷰·인증은 Avo가 자동 제공하므로 건드리지 않는다. 게이트웨이 사이드바에는 xaisimtier `/admin`으로 가는 외부 링크 1줄만 추가한다.

**Tech Stack:** Rails 8, Avo 3, RSpec, Devise (기존 admin 게이트), Active Storage (첨부).

## Global Constraints

- 대상 앱: `xaisimtier` (경로 `/Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier`)
- 모델은 이미 존재: `CaseStudy`(slug/title_ko 필수), `CaseMedium`(enum kind: youtube/pdf/html), `CaseComment`(enum status: pending/approved/hidden). **모델·마이그레이션 신규 생성 금지.**
- Avo Resource 클래스명 규칙: `Avo::Resources::<ModelName>` (예: `Avo::Resources::CaseStudy`)
- admin 인증: Devise + `User#admin` (기존). 신규 인증 코드 금지.
- 공개측(`case_studies_controller.rb`, `/cases` 갤러리) 코드는 **무변경**.
- 게이트웨이 링크 URL은 하드코딩 금지 → `ENV.fetch("XIMTIER_SITE_ADMIN_URL", "#")`.
- 테스트: RSpec, `sign_in`(Devise 헬퍼) + `create(:user, :admin)` factory 사용.
- 커밋은 한국어 Conventional Commits. 각 태스크 끝에 커밋.

---

### Task 1: CaseStudy Avo Resource

**Files:**
- Create: `app/avo/resources/case_study.rb`
- Test: `spec/requests/admin_case_studies_spec.rb`

**Interfaces:**
- Consumes: 기존 `CaseStudy` 모델(필드: slug, title_ko, title_en, industry, summary_ko/en, body_html_ko/en, published, likes_count, position, published_at, hero_image 첨부, case_media/case_comments has_many)
- Produces: `/admin/resources/case_studies` CRUD 경로 (Avo 자동 생성)

- [ ] **Step 1: Write the failing test**

```ruby
# spec/requests/admin_case_studies_spec.rb
require "rails_helper"

RSpec.describe "Admin CaseStudy resource", type: :request do
  it "lets an admin list case studies" do
    admin = create(:user, :admin)
    sign_in admin
    get "/admin/resources/case_studies"
    expect(response).to have_http_status(:ok)
  end

  it "redirects a non-admin away from case studies" do
    sign_in create(:user, admin: false)
    get "/admin/resources/case_studies"
    expect(response).to redirect_to("/users/sign_in")
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bundle exec rspec spec/requests/admin_case_studies_spec.rb`
Expected: FAIL — Avo가 `case_studies` Resource를 모름 (라우팅 에러 또는 404)

- [ ] **Step 3: Create the resource**

```ruby
# app/avo/resources/case_study.rb
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

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bundle exec rspec spec/requests/admin_case_studies_spec.rb`
Expected: PASS (2 examples, 0 failures)

- [ ] **Step 5: Commit**

```bash
git add app/avo/resources/case_study.rb spec/requests/admin_case_studies_spec.rb
git commit -m "feat(admin): CaseStudy Avo Resource — 사례 CRUD + hero 첨부 + 다국어 필드"
```

---

### Task 2: CaseMedium Avo Resource

**Files:**
- Create: `app/avo/resources/case_medium.rb`
- Test: `spec/requests/admin_case_media_spec.rb`

**Interfaces:**
- Consumes: 기존 `CaseMedium` 모델(belongs_to case_study, enum kind, youtube_url, embed_html, pdf 첨부, title, caption, position). `CaseMedium.kinds` → `{"youtube"=>0,"pdf"=>1,"html"=>2}`
- Produces: `/admin/resources/case_media` CRUD 경로

- [ ] **Step 1: Write the failing test**

```ruby
# spec/requests/admin_case_media_spec.rb
require "rails_helper"

RSpec.describe "Admin CaseMedium resource", type: :request do
  it "lets an admin list case media" do
    sign_in create(:user, :admin)
    get "/admin/resources/case_media"
    expect(response).to have_http_status(:ok)
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bundle exec rspec spec/requests/admin_case_media_spec.rb`
Expected: FAIL — `case_media` Resource 미정의

- [ ] **Step 3: Create the resource**

```ruby
# app/avo/resources/case_medium.rb
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

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bundle exec rspec spec/requests/admin_case_media_spec.rb`
Expected: PASS (1 example, 0 failures)

- [ ] **Step 5: Commit**

```bash
git add app/avo/resources/case_medium.rb spec/requests/admin_case_media_spec.rb
git commit -m "feat(admin): CaseMedium Avo Resource — 유튜브/PDF/HTML 매체 관리"
```

---

### Task 3: CaseComment Avo Resource

**Files:**
- Create: `app/avo/resources/case_comment.rb`
- Test: `spec/requests/admin_case_comments_spec.rb`

**Interfaces:**
- Consumes: 기존 `CaseComment` 모델(belongs_to case_study, enum status, author_name, body). `CaseComment.statuses` → `{"pending"=>0,"approved"=>1,"hidden"=>2}`
- Produces: `/admin/resources/case_comments` CRUD 경로

- [ ] **Step 1: Write the failing test**

```ruby
# spec/requests/admin_case_comments_spec.rb
require "rails_helper"

RSpec.describe "Admin CaseComment resource", type: :request do
  it "lets an admin list case comments" do
    sign_in create(:user, :admin)
    get "/admin/resources/case_comments"
    expect(response).to have_http_status(:ok)
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bundle exec rspec spec/requests/admin_case_comments_spec.rb`
Expected: FAIL — `case_comments` Resource 미정의

- [ ] **Step 3: Create the resource**

```ruby
# app/avo/resources/case_comment.rb
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

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bundle exec rspec spec/requests/admin_case_comments_spec.rb`
Expected: PASS (1 example, 0 failures)

- [ ] **Step 5: Commit**

```bash
git add app/avo/resources/case_comment.rb spec/requests/admin_case_comments_spec.rb
git commit -m "feat(admin): CaseComment Avo Resource — 댓글 status 승인/거부"
```

---

### Task 4: 게이트웨이 사이드바 "콘텐츠 관리" 링크

**Files:**
- Modify: `/Volumes/E_SSD/02_GitHub.nosync/0029_XimTier_SaaS_Deploy/ximtier_gateway/app/views/shared/_sidebar.html.erb`
- Modify: `/Volumes/E_SSD/02_GitHub.nosync/0029_XimTier_SaaS_Deploy/ximtier_gateway/config/locales/ko.yml`

**Interfaces:**
- Consumes: 기존 사이드바의 "운영 관리"(`nav.operations`) 섹션 — 마지막 항목은 `domains_path` 링크
- Produces: 그 아래 xaisimtier `/admin`으로 가는 외부 링크 1개

- [ ] **Step 1: locale 키 추가**

`config/locales/ko.yml`의 `nav:` 블록에서 `domains:` 키 바로 다음 줄에 추가:

```yaml
      content: "콘텐츠 관리"
```

(들여쓰기는 같은 블록의 기존 `domains:` 항목과 정확히 일치시킬 것. 값만 다르고 위치는 형제.)

- [ ] **Step 2: 사이드바 링크 추가**

`app/views/shared/_sidebar.html.erb`에서 `domains_path` 링크 블록(`<% end %>`) 바로 다음,
`<div class="nav-label"><%= t("nav.integration") %></div>` 앞에 삽입:

```erb
    <%= link_to ENV.fetch("XIMTIER_SITE_ADMIN_URL", "#"),
          class: "nav-item", target: "_blank", title: t("nav.content") do %>
      <i class="lni lni-image-1"></i> <span><%= t("nav.content") %></span>
    <% end %>
```

- [ ] **Step 3: 렌더 확인 (문법 검증)**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0029_XimTier_SaaS_Deploy/ximtier_gateway && bin/rails runner 'ApplicationController.render(partial: "shared/sidebar") rescue nil; puts "erb ok"'`
Expected: `erb ok` 출력 (ERB 파싱 에러 없음). 렌더 자체가 헬퍼 의존으로 실패해도 문법 에러가 아니면 통과로 간주 — 실패 시 `bin/rails zeitwerk:check` 대신 `ruby -c`로 ERB 컴파일 확인.

- [ ] **Step 4: Commit (게이트웨이 저장소)**

```bash
cd /Volumes/E_SSD/02_GitHub.nosync/0029_XimTier_SaaS_Deploy/ximtier_gateway
git add app/views/shared/_sidebar.html.erb config/locales/ko.yml
git commit -m "feat(nav): 운영 관리에 콘텐츠 관리 링크 추가 — xaisimtier /admin 연결"
```

---

### Task 5: 캐릭터 저니 UI 검증 (운영자)

**Files:** (없음 — 검증 전용)

- [ ] **Step 1: xaisimtier 서버 기동**

Run: `cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && bin/rails server -p 3000` (백그라운드)

- [ ] **Step 2: seed로 admin 유저 + 사례 확보**

Run: `ADMIN_PW='<로컬에서 직접 지정>' bin/rails runner 'User.find_or_create_by(email:"admin@ximtier.dev"){|u| u.password=ENV.fetch("ADMIN_PW"); u.admin=true; u.name="Admin"; u.company="X"; u.role="PM"; u.industry=:manufacturing; u.locale="ko"}; load Rails.root.join("db/seeds/case_studies.rb")'`

> ⚠️ 이 저장소는 public 이다. admin 비밀번호를 문서에 적지 말 것 — 반드시 ENV 로 주입한다.
Expected: 에러 없이 완료. CaseStudy 3건 존재.

- [ ] **Step 3: 저니 시나리오 실제 클릭 (browse/gstack)**

설계 문서의 검증 표 7스텝을 실제 클릭으로 수행하고 각 스텝 스크린샷 저장:
1. admin 로그인 → `/admin/resources/case_studies` 목록 확인 → `/tmp/j-cases-1.png`
2. New → title_ko만 입력 저장 → `/tmp/j-cases-2.png`
3. 그 사례 Show → Case media New → 유튜브 매체 추가 → `/tmp/j-cases-3.png`
4. published 체크 후 공개 `/cases`에서 노출 확인 → `/tmp/j-cases-4.png`
5. Case comment(사전 seed로 pending 1건 생성) status→approved → 공개 상세 노출 → `/tmp/j-cases-5.png`
6. 사례 Edit 저장 → 변경 반영 → `/tmp/j-cases-6.png`
7. 사례 Delete → 목록에서 제거 확인 → `/tmp/j-cases-7.png`

- [ ] **Step 4: 결과 보고**

저니 테스트 표(PASS/FAIL + 스크린샷 경로)를 대표님께 제출. FAIL 항목은 즉시 수정 후 재테스트.

- [ ] **Step 5: 서버 종료 + push**

```bash
# 서버 프로세스 종료
cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier && git push
cd /Volumes/E_SSD/02_GitHub.nosync/0029_XimTier_SaaS_Deploy/ximtier_gateway && git push
```

---

## Self-Review

**Spec coverage:**
- CaseStudy Resource → Task 1 ✓
- CaseMedium Resource → Task 2 ✓
- CaseComment Resource(status 승인) → Task 3 ✓
- CaseStudy에 has_many 연결 → Task 1 fields에 포함 ✓
- Avo 인증(Devise+admin) 재사용 → Task 1 test가 검증 ✓
- 게이트웨이 링크 + locale → Task 4 ✓
- 캐릭터 저니 검증 → Task 5 ✓
- 다국어 title_ko 필수 → Task 1 field `required: true` + 모델 validation ✓

**Placeholder scan:** 모든 step에 실제 코드/명령 포함. TBD/TODO 없음 ✓

**Type consistency:**
- `CaseMedium.kinds` / `CaseComment.statuses` — 모델 enum과 일치 확인됨 ✓
- Resource 클래스명 `Avo::Resources::CaseStudy` 등 — 기존 `Avo::Resources::Comment` 규칙과 일치 ✓
- 경로 `/admin/resources/case_studies` (복수, snake) — Avo 3 기본 규칙 ✓

**주의 사항 (구현자 참고):**
- Avo 3의 정확한 index 경로가 `/admin/resources/case_studies`가 아닐 수 있음(버전에 따라 `/avo` 프리픽스 등). Task 1 Step 2에서 실패 시, `bundle exec rails routes | grep case_stud`로 실제 경로를 확인하고 spec의 경로를 그에 맞춰 조정할 것. Resource 정의 자체는 동일.

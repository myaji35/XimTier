require "rails_helper"

# 관리자 사례 갤러리 등록 — /admin 에서 실제로 등록·수정·발행이 되는지 검증한다.
# 기존 테스트는 "목록이 뜬다" 뿐이라 등록 자체가 미검증이었다.
RSpec.describe "Admin CaseStudy resource", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "접근 제어" do
    it "lets an admin list case studies" do
      sign_in admin
      get "/admin/resources/case_studies"
      expect(response).to have_http_status(:ok)
    end

    it "redirects a non-admin away from case studies" do
      sign_in create(:user, admin: false)
      get "/admin/resources/case_studies"
      expect(response).to redirect_to("/users/sign_in")
    end

    it "비로그인은 차단된다" do
      get "/admin/resources/case_studies"
      expect(response).to redirect_to("/users/sign_in")
    end
  end

  describe "등록" do
    before { sign_in admin }

    it "새 사례를 등록할 수 있다" do
      expect {
        post "/admin/resources/case_studies", params: {
          case_study: {
            slug: "incheon-smart-factory",
            title_ko: "인천 스마트팩토리 — 설비 가동률 12% 개선",
            title_en: "Incheon Smart Factory",
            industry: "제조",
            summary_ko: "설비 로그 8개월치로 병목 공정을 역산했습니다.",
            published: "1"
          }
        }
      }.to change(CaseStudy, :count).by(1)

      c = CaseStudy.find_by(slug: "incheon-smart-factory")
      expect(c.title_ko).to include("스마트팩토리")
      expect(c.published).to be(true)
      # published 로 저장하면 발행 시각이 자동으로 찍힌다 (set_published_at)
      expect(c.published_at).to be_present
    end

    it "slug 가 중복되면 등록되지 않는다" do
      create_case(slug: "duplicated")

      expect {
        post "/admin/resources/case_studies", params: {
          case_study: { slug: "duplicated", title_ko: "중복 시도" }
        }
      }.not_to change(CaseStudy, :count)
    end

    # slug 는 URL 에 그대로 쓰인다. 공백·대문자·한글이 들어가면 링크가 깨진다.
    it "slug 형식이 어긋나면 등록되지 않는다" do
      expect {
        post "/admin/resources/case_studies", params: {
          case_study: { slug: "잘못된 SLUG", title_ko: "형식 위반" }
        }
      }.not_to change(CaseStudy, :count)
    end

    it "제목 없이는 등록되지 않는다" do
      expect {
        post "/admin/resources/case_studies", params: {
          case_study: { slug: "no-title", title_ko: "" }
        }
      }.not_to change(CaseStudy, :count)
    end
  end

  describe "수정" do
    before { sign_in admin }
    let!(:study) { create_case(slug: "editable", title_ko: "원래 제목", published: false) }

    it "제목을 고칠 수 있다" do
      put "/admin/resources/case_studies/#{study.id}", params: {
        case_study: { slug: "editable", title_ko: "바뀐 제목" }
      }
      expect(study.reload.title_ko).to eq("바뀐 제목")
    end

    it "발행 상태를 켤 수 있다" do
      put "/admin/resources/case_studies/#{study.id}", params: {
        case_study: { slug: "editable", title_ko: "원래 제목", published: "1" }
      }
      expect(study.reload.published).to be(true)
    end
  end

  describe "발행 ↔ 공개 갤러리 연결" do
    it "발행하면 공개 갤러리 목록에 나온다" do
      sign_in admin
      post "/admin/resources/case_studies", params: {
        case_study: { slug: "published-case", title_ko: "발행된 사례입니다", published: "1" }
      }

      get "/ko/cases"
      expect(response.body).to include("발행된 사례입니다")
    end

    # 발행 전 사례가 공개 목록에 새어나가면 안 된다.
    it "미발행이면 공개 갤러리에 나오지 않는다" do
      create_case(slug: "draft-case", title_ko: "작성중인 초안입니다", published: false)

      get "/ko/cases"
      expect(response.body).not_to include("작성중인 초안입니다")
    end

    it "미발행 사례의 상세 페이지는 열리지 않는다" do
      create_case(slug: "draft-detail", published: false)

      get "/ko/cases/draft-detail/gallery"
      expect(response).not_to have_http_status(:ok)
    end
  end

  private

  def create_case(slug:, title_ko: "테스트 사례", published: true)
    CaseStudy.create!(slug: slug, title_ko: title_ko, published: published)
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

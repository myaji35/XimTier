require "rails_helper"

RSpec.describe "자체 사례 콘텐츠 관리", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "접근 제어" do
    it "비로그인 사용자를 로그인 화면으로 보낸다" do
      get "/admin/cases"
      expect(response).to redirect_to("/users/sign_in")
    end

    it "비관리자를 로그인 화면으로 보낸다" do
      sign_in create(:user)
      get "/admin/cases"
      expect(response).to redirect_to("/users/sign_in")
    end

    it "관리자에게 목록을 보여 준다" do
      CaseStudy.create!(slug: "admin-list", title_ko: "목록 사례")
      sign_in admin

      get "/admin/cases"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("목록 사례")
    end
  end

  describe "CRUD" do
    before { sign_in admin }

    it "사례를 생성한다" do
      expect {
        post "/admin/cases", params: {
          case_study: { slug: "new-admin-case", title_ko: "새 사례", published: "1", position: "2" }
        }
      }.to change(CaseStudy, :count).by(1)

      expect(response).to redirect_to("/admin/cases/new-admin-case")
    end

    it "검증 오류를 한글로 보여 준다" do
      post "/admin/cases", params: { case_study: { slug: "잘못된 SLUG", title_ko: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("제목(한국어) 값을 입력해 주세요")
      expect(response.body).to include("슬러그 소문자·숫자·하이픈만")
    end

    it "slug 로 사례를 수정한다" do
      study = CaseStudy.create!(slug: "edit-by-slug", title_ko: "수정 전")

      patch "/admin/cases/edit-by-slug", params: {
        case_study: { slug: "edit-by-slug", title_ko: "수정 후", industry: "제조" }
      }

      expect(response).to redirect_to("/admin/cases/edit-by-slug")
      expect(study.reload.title_ko).to eq("수정 후")
    end

    it "사례를 삭제한다" do
      study = CaseStudy.create!(slug: "delete-by-slug", title_ko: "삭제 대상")

      expect { delete "/admin/cases/#{study.slug}" }.to change(CaseStudy, :count).by(-1)
      expect(response).to redirect_to("/admin/cases")
    end
  end

  describe "매체 관리" do
    before { sign_in admin }
    let!(:study) { CaseStudy.create!(slug: "media-by-slug", title_ko: "매체 사례") }

    it "매체를 추가하고 삭제한다" do
      expect {
        post "/admin/cases/#{study.slug}/media", params: {
          case_medium: { kind: "youtube", title: "영상", youtube_url: "https://youtu.be/dQw4w9WgXcQ" }
        }
      }.to change(CaseMedium, :count).by(1)

      medium = CaseMedium.last
      expect {
        delete "/admin/cases/#{study.slug}/media/#{medium.id}"
      }.to change(CaseMedium, :count).by(-1)
    end
  end

  it "공개 사례 목록에는 계속 발행된 사례만 노출한다" do
    CaseStudy.create!(slug: "public-unchanged", title_ko: "공개 유지 사례", published: true)
    CaseStudy.create!(slug: "draft-unchanged", title_ko: "초안 유지 사례", published: false)

    get "/ko/cases"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("공개 유지 사례")
    expect(response.body).not_to include("초안 유지 사례")
  end
end

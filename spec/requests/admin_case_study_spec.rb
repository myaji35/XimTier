require "rails_helper"

# CaseStudy#to_param 이 slug 를 돌려주는데 Avo 기본 find_record 는 기본키로만
# 조회해서, 목록의 편집 링크를 눌러도 전부 404 였다. (ISS-027)
# 테스트가 없어 오래 방치됐던 결함이라 상세·편집·수정 경로를 고정한다.
RSpec.describe "Avo 사례 콘텐츠 관리", type: :request do
  let(:password) { "adminpass123" }
  let(:admin) do
    create(:user, email: "avo-admin@example.com", password: password)
      .tap { |u| u.confirm; u.grant_admin! }
  end
  let!(:case_study) do
    CaseStudy.create!(slug: "avo-crud-spec", title_ko: "CRUD 스펙 사례")
  end

  before do
    post "/users/sign_in", params: { user: { email: admin.email, password: password } }
  end

  it "slug 로 상세를 연다" do
    get "/admin/resources/case_studies/#{case_study.slug}"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("CRUD 스펙 사례")
  end

  it "slug 로 편집 폼을 연다" do
    get "/admin/resources/case_studies/#{case_study.slug}/edit"

    expect(response).to have_http_status(:ok)
  end

  it "수정이 저장된다" do
    put "/admin/resources/case_studies/#{case_study.slug}",
        params: { case_study: { title_ko: "수정된 제목" } }

    expect(case_study.reload.title_ko).to eq("수정된 제목")
  end

  # Avo 내부 일부 경로(일괄 액션 등)는 기본키로 부른다.
  it "숫자 id 로도 찾을 수 있다" do
    get "/admin/resources/case_studies/#{case_study.id}"

    expect(response).to have_http_status(:ok)
  end
end

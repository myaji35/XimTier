require "rails_helper"

# 사례 매체(유튜브·PDF·HTML) 등록 — 갤러리의 실제 콘텐츠가 여기서 들어간다.
# 기존 테스트는 "목록이 뜬다" 뿐이라 등록·URL 파싱이 미검증이었다.
RSpec.describe "Admin CaseMedium resource", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:study) { CaseStudy.create!(slug: "media-host", title_ko: "매체 호스트 사례") }

  it "lets an admin list case media" do
    sign_in admin
    get "/admin/resources/case_media"
    expect(response).to have_http_status(:ok)
  end

  it "비관리자는 차단된다" do
    sign_in create(:user, admin: false)
    get "/admin/resources/case_media"
    expect(response).to redirect_to("/users/sign_in")
  end

  describe "유튜브 영상 등록" do
    before { sign_in admin }

    it "영상을 등록할 수 있다" do
      expect {
        post "/admin/resources/case_media", params: {
          case_medium: {
            case_study_id: study.id, kind: "youtube",
            title: "공정 개선 데모",
            youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
          }
        }
      }.to change(CaseMedium, :count).by(1)

      expect(CaseMedium.last.youtube_id).to eq("dQw4w9WgXcQ")
    end

    # 관리자가 어떤 형식으로 붙여넣든 동작해야 한다.
    # 실패하면 영상이 안 나오는데 화면상 원인을 알 수 없다.
    {
      "watch"   => "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "youtu.be" => "https://youtu.be/dQw4w9WgXcQ",
      "shorts"  => "https://www.youtube.com/shorts/dQw4w9WgXcQ",
      "embed"   => "https://www.youtube.com/embed/dQw4w9WgXcQ",
      "타임스탬프 포함" => "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42s"
    }.each do |form, url|
      it "#{form} 형식 URL에서 영상 ID를 뽑아낸다" do
        m = CaseMedium.create!(case_study: study, kind: :youtube, youtube_url: url)
        expect(m.youtube_id).to eq("dQw4w9WgXcQ")
        expect(m.youtube_embed_url).to eq("https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ")
      end
    end

    it "youtube 인데 URL 이 없으면 등록되지 않는다" do
      expect {
        post "/admin/resources/case_media", params: {
          case_medium: { case_study_id: study.id, kind: "youtube", youtube_url: "" }
        }
      }.not_to change(CaseMedium, :count)
    end
  end

  describe "HTML 매체 등록" do
    before { sign_in admin }

    it "본문 HTML 이 있으면 등록된다" do
      expect {
        post "/admin/resources/case_media", params: {
          case_medium: {
            case_study_id: study.id, kind: "html",
            title: "인터랙티브 차트", embed_html: "<div>chart</div>"
          }
        }
      }.to change(CaseMedium, :count).by(1)
    end

    it "html 인데 본문이 없으면 등록되지 않는다" do
      expect {
        post "/admin/resources/case_media", params: {
          case_medium: { case_study_id: study.id, kind: "html", embed_html: "" }
        }
      }.not_to change(CaseMedium, :count)
    end
  end

  describe "PDF 매체" do
    it "pdf 인데 파일이 없으면 등록되지 않는다" do
      m = CaseMedium.new(case_study: study, kind: :pdf)
      expect(m).not_to be_valid
      expect(m.errors[:pdf]).to be_present
    end
  end

  describe "표시 순서" do
    it "position 순으로 정렬된다 (상세 페이지 노출 순서)" do
      CaseMedium.create!(case_study: study, kind: :youtube,
                         youtube_url: "https://youtu.be/aaaaaaaaaaa", position: 2, title: "두번째")
      CaseMedium.create!(case_study: study, kind: :youtube,
                         youtube_url: "https://youtu.be/bbbbbbbbbbb", position: 1, title: "첫번째")

      expect(study.case_media.map(&:title)).to eq(%w[첫번째 두번째])
    end
  end

  describe "사례 삭제 시" do
    it "매체도 함께 삭제된다 (고아 레코드 방지)" do
      CaseMedium.create!(case_study: study, kind: :youtube, youtube_url: "https://youtu.be/ccccccccccc")

      expect { study.destroy }.to change(CaseMedium, :count).by(-1)
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

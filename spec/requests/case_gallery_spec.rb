require "rails_helper"

# 공개 사례 갤러리 (/cases, /cases/:slug/gallery).
# 관리자가 등록한 콘텐츠가 방문자에게 실제로 어떻게 보이는지 검증한다.
# 기존 case_studies_spec 은 /cases/:slug (별도 정적 페이지)만 다뤄 갤러리는 미검증이었다.
RSpec.describe "공개 사례 갤러리", type: :request do
  def create_case(slug:, title:, published: true, likes: 0)
    CaseStudy.create!(slug: slug, title_ko: title, published: published, likes_count: likes)
  end

  describe "목록 (/cases)" do
    it "발행된 사례가 보인다" do
      create_case(slug: "visible-one", title: "보이는 사례")
      get "/ko/cases"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("보이는 사례")
    end

    it "사례가 없으면 빈 상태 안내가 나온다" do
      get "/ko/cases"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("아직 등록된 사례가 없습니다")
    end

    it "영문 페이지도 열린다" do
      create_case(slug: "en-case", title: "영문 확인")
      get "/en/cases"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "정렬" do
    let!(:old_popular) { create_case(slug: "old-popular", title: "오래됐지만 인기", likes: 50) }
    let!(:new_quiet)   { create_case(slug: "new-quiet",   title: "최신이지만 조용", likes: 1) }

    before { old_popular.update_column(:published_at, 1.year.ago) }

    it "기본은 최신순이다" do
      get "/ko/cases"
      expect(response.body.index("최신이지만 조용")).to be < response.body.index("오래됐지만 인기")
    end

    it "좋아요순으로 바꿀 수 있다" do
      get "/ko/cases?sort=likes"
      expect(response.body.index("오래됐지만 인기")).to be < response.body.index("최신이지만 조용")
    end

    # 임의 값이 들어와도 깨지지 않고 기본(최신순)으로 떨어져야 한다.
    it "알 수 없는 정렬값은 최신순으로 처리된다" do
      get "/ko/cases?sort=' OR 1=1--"
      expect(response).to have_http_status(:ok)
      expect(response.body.index("최신이지만 조용")).to be < response.body.index("오래됐지만 인기")
    end
  end

  describe "상세 (/cases/:slug/gallery)" do
    let!(:study) { create_case(slug: "detail-case", title: "상세 사례") }

    it "발행된 사례의 상세가 열린다" do
      get "/ko/cases/detail-case/gallery"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("상세 사례")
    end

    it "없는 slug 는 404" do
      get "/ko/cases/no-such-case/gallery"
      expect(response).to have_http_status(:not_found)
    end

    it "유튜브 영상이 embed 로 렌더된다" do
      study.case_media.create!(kind: :youtube, youtube_url: "https://youtu.be/dQw4w9WgXcQ", title: "데모 영상")

      get "/ko/cases/detail-case/gallery"
      expect(response.body).to include("youtube-nocookie.com/embed/dQw4w9WgXcQ")
    end

    # 매체는 position 순으로 배치된다. 순서가 틀리면 스토리 흐름이 깨진다.
    it "매체가 position 순으로 배치된다" do
      study.case_media.create!(kind: :html, embed_html: "<p>두번째 매체</p>", position: 2)
      study.case_media.create!(kind: :html, embed_html: "<p>첫번째 매체</p>", position: 1)

      get "/ko/cases/detail-case/gallery"
      expect(response.body.index("첫번째 매체")).to be < response.body.index("두번째 매체")
    end
  end

  describe "좋아요" do
    let!(:study) { create_case(slug: "like-case", title: "좋아요 사례") }

    it "누르면 카운트가 오른다" do
      post "/ko/cases/like-case/like"
      expect(JSON.parse(response.body)["liked"]).to be(true)
      expect(study.reload.likes_count).to eq(1)
    end

    it "같은 방문자가 다시 누르면 취소된다" do
      post "/ko/cases/like-case/like"
      post "/ko/cases/like-case/like"
      expect(JSON.parse(response.body)["liked"]).to be(false)
      expect(study.reload.likes_count).to eq(0)
    end

    it "미발행 사례에는 좋아요를 누를 수 없다" do
      draft = create_case(slug: "draft-like", title: "초안", published: false)
      post "/ko/cases/draft-like/like"
      expect(response).to have_http_status(:not_found)
      expect(draft.reload.likes_count).to eq(0)
    end
  end
end

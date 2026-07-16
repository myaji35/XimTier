require "rails_helper"

# 댓글 승인 흐름 — 갤러리 댓글은 승인제다 (pending → approved/hidden).
# 승인 전 댓글이 공개 화면에 새면 스팸·비방이 그대로 노출된다.
# 기존 테스트는 "목록이 뜬다" 뿐이라 승인 자체가 미검증이었다.
RSpec.describe "Admin CaseComment resource", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:study) { CaseStudy.create!(slug: "comment-case", title_ko: "댓글 사례", published: true) }

  def comment(body:, status: :pending, name: "방문자")
    study.case_comments.create!(author_name: name, body: body, status: status)
  end

  # 관리자가 목록에서 댓글을 골라 액션을 실행하는 것과 같은 경로.
  def run_action(action, comment)
    post "/admin/resources/case_comments/actions",
         params: { fields: { avo_resource_ids: comment.id.to_s }, action_id: action }
  end

  describe "접근 제어" do
    it "lets an admin list case comments" do
      sign_in admin
      get "/admin/resources/case_comments"
      expect(response).to have_http_status(:ok)
    end

    it "비관리자는 차단된다" do
      sign_in create(:user, admin: false)
      get "/admin/resources/case_comments"
      expect(response).to redirect_to("/users/sign_in")
    end
  end

  describe "방문자가 댓글을 남기면" do
    it "승인 대기(pending) 상태로 저장된다" do
      expect {
        post "/ko/cases/comment-case/comments", params: {
          case_comment: { author_name: "김방문", body: "좋은 사례네요" }
        }
      }.to change(CaseComment, :count).by(1)

      expect(CaseComment.last).to be_pending
    end

    it "검토 안내를 받는다" do
      post "/ko/cases/comment-case/comments", params: {
        case_comment: { author_name: "김방문", body: "좋은 사례네요" }
      }
      follow_redirect!
      expect(response.body).to include("검토")
    end

    it "이름이나 본문이 없으면 저장되지 않는다" do
      expect {
        post "/ko/cases/comment-case/comments", params: {
          case_comment: { author_name: "", body: "" }
        }
      }.not_to change(CaseComment, :count)
    end

    # 방문자가 status 를 직접 넘겨 승인 절차를 건너뛸 수 없어야 한다.
    it "status 를 직접 넘겨도 승인되지 않는다" do
      post "/ko/cases/comment-case/comments", params: {
        case_comment: { author_name: "우회시도", body: "바로 게시되나", status: "approved" }
      }
      expect(CaseComment.last).to be_pending
    end
  end

  describe "공개 화면 노출" do
    it "승인된 댓글만 보인다" do
      comment(body: "승인된 댓글입니다", status: :approved)
      comment(body: "대기중인 댓글입니다", status: :pending)
      comment(body: "숨겨진 댓글입니다", status: :hidden)

      get "/ko/cases/comment-case/gallery"
      expect(response.body).to include("승인된 댓글입니다")
      expect(response.body).not_to include("대기중인 댓글입니다")
      expect(response.body).not_to include("숨겨진 댓글입니다")
    end

    it "작성 시각 순으로 보인다" do
      c1 = comment(body: "먼저 쓴 댓글", status: :approved)
      c2 = comment(body: "나중 쓴 댓글", status: :approved)
      c1.update_column(:created_at, 2.days.ago)

      expect(study.case_comments.visible.map(&:id)).to eq([ c1.id, c2.id ])
    end
  end

  describe "관리자 승인 액션" do
    before { sign_in admin }

    it "승인하면 공개 화면에 나타난다" do
      c = comment(body: "승인 대기 댓글")
      run_action("Avo::Actions::ApproveComment", c)

      expect(c.reload).to be_approved
      get "/ko/cases/comment-case/gallery"
      expect(response.body).to include("승인 대기 댓글")
    end

    it "숨기면 공개 화면에서 사라진다" do
      c = comment(body: "숨길 댓글", status: :approved)
      run_action("Avo::Actions::HideComment", c)

      expect(c.reload).to be_hidden
      get "/ko/cases/comment-case/gallery"
      expect(response.body).not_to include("숨길 댓글")
    end
  end

  describe "사례 삭제 시" do
    it "댓글도 함께 삭제된다 (고아 레코드 방지)" do
      comment(body: "삭제될 댓글", status: :approved)
      expect { study.destroy }.to change(CaseComment, :count).by(-1)
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

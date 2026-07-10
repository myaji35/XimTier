class CaseStudiesController < ApplicationController
  before_action :set_case, only: %i[show toggle_like create_comment]

  # 갤러리 인덱스 — 정렬: 최신(기본) / 좋아요순
  def index
    scope = CaseStudy.published.includes(:case_media, hero_image_attachment: :blob)
    @sort = params[:sort] == "likes" ? "likes" : "recent"
    @cases = @sort == "likes" ? scope.most_liked : scope.recent
  end

  # 상세 — 미디어 룸 + 설명 + 승인된 댓글
  def show
    @media    = @case.case_media
    @comments = @case.case_comments.visible
    @liked    = @case.case_likes.exists?(visitor_token: visitor_token)
  end

  # 익명 좋아요 토글 (visitor_token 중복 방지)
  def toggle_like
    like = @case.case_likes.find_by(visitor_token: visitor_token)
    if like
      like.destroy
      liked = false
    else
      @case.case_likes.create(visitor_token: visitor_token)
      liked = true
    end
    @case.update_column(:likes_count, @case.case_likes.count)
    render json: { liked: liked, likes_count: @case.likes_count }
  end

  # 승인제 댓글 — pending 저장 후 안내
  def create_comment
    comment = @case.case_comments.new(comment_params.merge(status: :pending))
    if comment.save
      redirect_to case_gallery_path(slug: @case.slug, locale: I18n.locale),
                  notice: t("cases_gallery.comment_submitted", default: "댓글이 등록되었습니다. 검토 후 게시됩니다.")
    else
      redirect_to case_gallery_path(slug: @case.slug, locale: I18n.locale),
                  alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def set_case
    @case = CaseStudy.published.find_by!(slug: params[:slug])
  end

  def comment_params
    params.require(:case_comment).permit(:author_name, :body)
  end

  # 브라우저별 영구 토큰 — 익명 좋아요 중복 방지용 (1년 쿠키)
  def visitor_token
    cookies.permanent[:xim_visitor] ||= SecureRandom.uuid
  end
end

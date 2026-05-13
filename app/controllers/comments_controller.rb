class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    demo_request = current_user.demo_requests.find(params[:demo_request_id])
    comment = demo_request.comments.build(
      body: params.dig(:comment, :body),
      user: current_user,
      by_admin: false
    )
    if comment.save
      redirect_to dashboard_path(locale: I18n.locale), notice: I18n.t("dashboard.comment_added", default: "코멘트가 등록되었습니다.")
    else
      redirect_to dashboard_path(locale: I18n.locale), alert: comment.errors.full_messages.join(", ")
    end
  end
end

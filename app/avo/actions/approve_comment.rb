class Avo::Actions::ApproveComment < Avo::BaseAction
  self.name = "댓글 승인"
  self.message = "선택한 댓글을 공개 상태로 전환합니다."

  def handle(query:, **_args)
    query.each { |comment| comment.update(status: :approved) }
    succeed "#{query.count}개 댓글을 승인했습니다."
    reload
  end
end

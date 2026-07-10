class Avo::Actions::HideComment < Avo::BaseAction
  self.name = "댓글 숨김"
  self.message = "선택한 댓글을 비공개로 전환합니다."

  def handle(query:, **_args)
    query.each { |comment| comment.update(status: :hidden) }
    succeed "#{query.count}개 댓글을 숨김 처리했습니다."
    reload
  end
end

class Avo::Actions::UnsuspendUser < Avo::BaseAction
  self.name = "회원 정지 해제"
  self.message = "선택한 회원의 정지를 해제합니다."

  def handle(query:, **_args)
    query.each(&:unsuspend!)
    succeed "#{query.count}명의 회원 정지를 해제했습니다."
    reload
  end
end

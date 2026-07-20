class Avo::Actions::SuspendUser < Avo::BaseAction
  self.name = "회원 정지"
  self.message = "선택한 회원의 로그인을 정지합니다."

  def fields
    field :reason, as: :textarea, name: "정지 사유", required: true
  end

  def handle(query:, fields:, **_args)
    query.each { |user| user.suspend!(reason: fields[:reason]) }
    succeed "#{query.count}명의 회원을 정지했습니다."
    reload
  end
end

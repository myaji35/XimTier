# 회원탈퇴 — 개인정보보호법 제21조·제36조 삭제권.
#
# 정책 (2026-07-16 결정):
#   - 데모 신청·코멘트·업로드 파일을 모두 삭제한다.
#     처리방침 3항이 "사용자 삭제 요청 시까지" 보유로 공표했고, 결제 모델이 없어
#     전자상거래법 5년 보존 의무에 걸리는 기록이 없다.
#   - 유예기간 없이 즉시 파기한다. 법이 요구하는 "지체 없이"에 부합한다.
#   - 남길 것이 없으므로 익명화가 아니라 하드 삭제다.
#
# 관리자 답변(by_admin) 코멘트는 해당 demo_request 에 매달려 함께 지워진다.
# 대화가 통째로 사라지므로 고아 레코드가 생기지 않는다.
class AccountClosing
  Result = Struct.new(:ok?, :error, keyword_init: true)

  # 본인 확인 후 탈퇴시킨다. 비밀번호가 맞지 않으면 아무것도 지우지 않는다.
  def self.call(user, current_password:)
    return Result.new(ok?: false, error: :password_required) if current_password.blank?
    return Result.new(ok?: false, error: :password_invalid) unless user.valid_password?(current_password)

    # dependent: :destroy 가 demo_requests → comments → data_file(ActiveStorage) 까지 연쇄시킨다.
    # 하나라도 실패하면 전부 되돌린다 — 계정만 지워지고 개인정보가 남는 상태를 막는다.
    ActiveRecord::Base.transaction do
      user.destroy_by_owner!
    end

    Result.new(ok?: true)
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid => e
    Rails.logger.error("[AccountClosing] user=#{user.id} 삭제 실패: #{e.message}")
    Result.new(ok?: false, error: :failed)
  end
end

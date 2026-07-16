class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :demo_requests, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Avo 인가는 avo-pro 전용이라 OSS 판에서는 정책이 호출되지 않는다.
  # 관리 화면에서 들어오는 위험한 변경은 모델에서 직접 막는다. — ISS-007 / ISS-008

  # admin 권한은 폼으로 켜고 끌 수 없다. 부여/회수는 콘솔에서 grant_admin!/revoke_admin! 로만.
  before_update :reject_admin_flag_change

  # 회원 삭제는 demo_requests·comments·업로드 파일까지 연쇄 삭제한다(dependent: :destroy).
  # 관리 화면의 실수나 코드 오류로 우연히 지워지지 않도록 기본은 막아두고,
  # 본인이 탈퇴를 신청한 경로(AccountClosing)에서만 명시적으로 연다. — ISS-002 / ISS-007
  before_destroy :block_hard_delete, prepend: true

  def grant_admin!
    update_column(:admin, true)
  end

  def revoke_admin!
    update_column(:admin, false)
  end

  # 본인 탈퇴 의사가 확인된 경우에만 물리 삭제를 허용한다.
  # AccountClosing 서비스가 이 경로로만 호출한다.
  def destroy_by_owner!
    @closing_by_owner = true
    destroy!
  ensure
    @closing_by_owner = false
  end

  enum :industry, {
    other:         0,
    manufacturing: 1,
    hospital:      2,
    public_sector: 3,
    finance:       4,
    smart_city:    5
  }

  validates :locale, inclusion: { in: %w[ko en] }

  scope :admins, -> { where(admin: true) }

  def display_name
    name.presence || email
  end

  private

  def reject_admin_flag_change
    return unless admin_changed?

    errors.add(:admin, :readonly)
    throw :abort
  end

  def block_hard_delete
    return if @closing_by_owner

    errors.add(:base, :hard_delete_blocked)
    throw :abort
  end
end

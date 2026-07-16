class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :demo_requests, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Avo 인가는 avo-pro 전용이라 OSS 판에서는 정책이 호출되지 않는다.
  # 관리 화면에서 들어오는 위험한 변경은 모델에서 직접 막는다. — ISS-007 / ISS-008

  # admin 권한은 폼으로 켜고 끌 수 없다. 부여/회수는 콘솔에서 grant_admin!/revoke_admin! 로만.
  before_update :reject_admin_flag_change

  # 회원 삭제는 demo_requests·comments 까지 연쇄 삭제한다(dependent: :destroy).
  # 정식 탈퇴 경로(소프트삭제 + 익명화)가 생기기 전까지 물리 삭제를 막는다. — ISS-002 선행
  before_destroy :block_hard_delete, prepend: true

  def grant_admin!
    update_column(:admin, true)
  end

  def revoke_admin!
    update_column(:admin, false)
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
    errors.add(:base, :hard_delete_blocked)
    throw :abort
  end
end

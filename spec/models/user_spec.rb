require "rails_helper"

RSpec.describe User, type: :model do
  describe "회원 정지" do
    it "사유 없이 정지할 수 없다" do
      user = create(:user)

      expect { user.suspend!(reason: " ") }.to raise_error(ArgumentError)
      expect(user.reload).not_to be_suspended
    end

    it "정지하면 사유와 시각이 함께 남고 인증이 막힌다" do
      user = create(:user)

      user.suspend!(reason: "서비스 악용")

      expect(user).to be_suspended
      expect(user.suspension_reason).to eq("서비스 악용")
      expect(user.suspended_at).to be_present
      expect(user.active_for_authentication?).to be false
      expect(user.inactive_message).to eq(:suspended)
    end

    it "해제하면 사유가 지워지고 인증이 복구된다" do
      user = create(:user)
      user.suspend!(reason: "서비스 악용")

      user.unsuspend!

      expect(user).not_to be_suspended
      expect(user.suspension_reason).to be_nil
      expect(user.active_for_authentication?).to be true
    end

    it "scope 로 정지 회원과 활성 회원을 가른다" do
      suspended = create(:user)
      active    = create(:user)
      suspended.suspend!(reason: "서비스 악용")

      expect(User.suspended).to include(suspended)
      expect(User.suspended).not_to include(active)
      expect(User.active).to include(active)
      expect(User.active).not_to include(suspended)
    end
  end
end

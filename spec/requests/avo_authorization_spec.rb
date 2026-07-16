require "rails_helper"

# ISS-007 / ISS-008 — Avo 인가(authorization)가 실제로 작동하는지 검증한다.
# authenticate_with(admin? 체크)는 "문을 통과했는가"까지만 본다.
# 문 안에서 무엇을 할 수 있는지는 정책이 정한다.
RSpec.describe "Avo authorization", type: :request do
  describe "비관리자" do
    it "회원 목록에 접근할 수 없다" do
      sign_in create(:user, admin: false)
      get "/admin/resources/users"
      expect(response).to redirect_to("/users/sign_in")
    end
  end

  describe "관리자" do
    let(:admin) { create(:user, :admin) }

    it "회원 목록을 볼 수 있다" do
      sign_in admin
      get "/admin/resources/users"
      expect(response).to have_http_status(:ok)
    end

    # ISS-008 — 권한 상승 경로 차단
    it "회원 수정 폼으로 admin 권한을 켤 수 없다" do
      sign_in admin
      victim = create(:user, admin: false)

      put "/admin/resources/users/#{victim.id}",
          params: { user: { admin: "1" } }

      expect(victim.reload.admin).to be(false)
    end

    it "회원을 삭제할 수 없다 (탈퇴 경로 부재 — ISS-002 선행)" do
      sign_in admin
      victim = create(:user, admin: false)

      expect {
        delete "/admin/resources/users/#{victim.id}"
      }.not_to change(User, :count)
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

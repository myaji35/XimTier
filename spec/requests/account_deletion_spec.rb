require "rails_helper"

# ISS-002 — 회원탈퇴 경로가 없어 삭제권이 보장되지 않았다 (개인정보보호법 제21조·제36조).
# 처리방침 5항이 "삭제 요청" 권리를, 3항이 "사용자 삭제 요청 시까지" 보유를 공표한 상태였다.
#
# 결정(2026-07-16): 데모 신청·코멘트·업로드 파일 전부 삭제. 유예기간 없이 즉시 처리.
# 결제 모델이 없어 전자상거래법 5년 보존 의무는 해당 없다.
RSpec.describe "회원탈퇴", type: :request do
  let(:password) { "secret123" }
  let(:user) { create(:user, password: password, email: "quit@test.com") }

  describe "탈퇴 실행" do
    it "본인 계정과 데모 신청·코멘트가 모두 삭제된다" do
      dr = user.demo_requests.create!(data_description: "내 신청", locale: "ko")
      dr.comments.create!(body: "내 코멘트", user: user, by_admin: false)
      sign_in user

      expect {
        delete "/ko/account", params: { current_password: password }
      }.to change(User, :count).by(-1)
        .and change(DemoRequest, :count).by(-1)
        .and change(Comment, :count).by(-1)
    end

    it "업로드한 데이터 파일도 삭제된다" do
      dr = user.demo_requests.create!(data_description: "파일 있는 신청", locale: "ko")
      dr.data_file.attach(
        io: StringIO.new("공정 로그 원본"),
        filename: "process.csv",
        content_type: "text/csv"
      )
      expect(dr.data_file).to be_attached
      sign_in user

      expect {
        delete "/ko/account", params: { current_password: password }
      }.to change(ActiveStorage::Attachment, :count).by(-1)
    end

    it "탈퇴 후에는 같은 계정으로 로그인할 수 없다" do
      sign_in user
      delete "/ko/account", params: { current_password: password }

      post "/users/sign_in", params: { user: { email: "quit@test.com", password: password } }
      get "/ko/dashboard"
      expect(response).to redirect_to("/users/sign_in")
    end

    # 되돌릴 수 없는 작업이므로 완료 사실을 반드시 알려야 한다.
    it "탈퇴 후 완료 안내가 보인다" do
      sign_in user
      delete "/ko/account", params: { current_password: password }
      follow_redirect!
      expect(response.body).to include(I18n.t("account.close.flash.done"))
    end

    it "탈퇴한 이메일로 재가입할 수 있다" do
      sign_in user
      delete "/ko/account", params: { current_password: password }

      expect {
        User.create!(email: "quit@test.com", password: "newpass123", locale: "ko")
      }.to change(User, :count).by(1)
    end
  end

  describe "오조작·악의 방지" do
    it "비밀번호가 틀리면 탈퇴되지 않는다" do
      sign_in user
      expect {
        delete "/ko/account", params: { current_password: "wrong-password" }
      }.not_to change(User, :count)
    end

    it "비밀번호를 안 보내면 탈퇴되지 않는다" do
      sign_in user
      expect {
        delete "/ko/account"
      }.not_to change(User, :count)
    end

    it "비로그인 상태로는 탈퇴 요청이 통하지 않는다" do
      user # 생성만
      expect {
        delete "/ko/account", params: { current_password: password }
      }.not_to change(User, :count)
      expect(response).to redirect_to("/users/sign_in")
    end

    it "다른 사람의 데이터는 지워지지 않는다" do
      other = create(:user, password: password)
      other.demo_requests.create!(data_description: "남의 신청", locale: "ko")
      sign_in user

      expect {
        delete "/ko/account", params: { current_password: password }
      }.not_to change { other.demo_requests.count }
      expect(User.exists?(other.id)).to be(true)
    end
  end

  describe "탈퇴 화면" do
    it "로그인 사용자에게 탈퇴 화면이 보인다" do
      sign_in user
      get "/ko/account/close"
      expect(response).to have_http_status(:ok)
    end

    it "비로그인은 로그인 페이지로" do
      get "/ko/account/close"
      expect(response).to redirect_to("/users/sign_in")
    end

    it "대시보드에서 탈퇴 화면으로 갈 수 있다 (경로가 노출된다)" do
      sign_in user
      get "/ko/dashboard"
      expect(response.body).to include("/ko/account/close")
    end
  end

  # ISS-007에서 넣은 물리삭제 가드는 관리 화면 실수를 막기 위한 것이다.
  # 탈퇴 경로에서만 열리고, 그 외에는 계속 막혀 있어야 한다.
  describe "물리삭제 가드" do
    it "탈퇴 경로가 아닌 곳에서는 여전히 삭제가 막힌다" do
      u = create(:user)
      expect(u.destroy).to be(false)
      expect(User.exists?(u.id)).to be(true)
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

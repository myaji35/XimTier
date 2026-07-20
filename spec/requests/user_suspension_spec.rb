require "rails_helper"

RSpec.describe "회원 정지 로그인", type: :request do
  let(:password) { "password123" }
  let(:user) do
    create(:user, email: "suspended@example.com", password: password).tap(&:confirm)
  end

  # 화면 본문이 아니라 세션·flash 로 판정한다.
  # 레이아웃이 flash 를 렌더하지 않아(별건 이슈) 본문 검사로는 차단 여부를 알 수 없다.
  it "정지된 회원은 로그인할 수 없고 해제 후 다시 로그인할 수 있다" do
    user.suspend!(reason: "서비스 악용")

    post "/users/sign_in", params: { user: { email: user.email, password: password } }
    expect(response).to redirect_to("/users/sign_in")
    expect(session["warden.user.user.key"]).to be_nil
    expect(flash[:alert]).to eq("계정이 정지되었습니다. 관리자에게 문의해 주세요.")

    user.unsuspend!
    post "/users/sign_in", params: { user: { email: user.email, password: password } }
    expect(session["warden.user.user.key"]).to be_present
  end
end

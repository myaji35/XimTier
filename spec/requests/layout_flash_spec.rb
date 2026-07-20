require "rails_helper"

RSpec.describe "레이아웃 flash 렌더", type: :request do
  let(:password) { "password123" }
  let(:user) do
    create(:user, email: "layout-flash@example.com", password: password).tap(&:confirm)
  end

  it "정지된 회원의 로그인 실패 메시지를 로그인 화면 본문에 표시한다" do
    user.suspend!(reason: "서비스 악용")

    post "/users/sign_in", params: { user: { email: user.email, password: password } }
    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("계정이 정지되었습니다")
  end

  it "메시지를 한 번만 그린다" do
    user.suspend!(reason: "서비스 악용")

    post "/users/sign_in", params: { user: { email: user.email, password: password } }
    follow_redirect!

    expect(response.body.scan("계정이 정지되었습니다").size).to eq(1)
  end

  # 페이지가 자체 flash 블록을 되살리면 레이아웃과 겹쳐 두 번 나온다.
  # 실제로 그렇게 회귀한 적이 있어(ISS-023) 자체 flash 를 가진 화면으로 고정 검증한다.
  it "자체 flash 블록이 있던 대시보드에서도 중복되지 않는다" do
    post "/users/sign_in", params: { user: { email: user.email, password: password } }
    get "/ko/dashboard"

    expect(response).to have_http_status(:ok)
    expect(response.body.scan("background:#E0F2FE").size).to be <= 1
  end
end

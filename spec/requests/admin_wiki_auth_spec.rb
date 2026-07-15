require "rails_helper"

# ISS-015 회귀 방지 — 관리자 위키 Basic Auth.
# 이 경로는 Devise를 우회하고 update_roadmap은 CSRF까지 skip하므로
# Basic Auth 비밀번호가 유일한 방어선이다. 폴백이 되살아나면 여기서 실패한다.
RSpec.describe "Admin::Wikis 인증", type: :request do
  def basic_auth(password)
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", password) }
  end

  let(:configured_password) { Rails.application.credentials.dig(:admin_wiki, :password) }

  it "credentials에 비밀번호가 설정되어 있다" do
    expect(configured_password).to be_present
  end

  it "인증 없이 접근하면 401" do
    get admin_wiki_path
    expect(response).to have_http_status(:unauthorized)
  end

  it "틀린 비밀번호면 401" do
    get admin_wiki_path, headers: basic_auth("definitely-not-the-password")
    expect(response).to have_http_status(:unauthorized)
  end

  it "설정된 비밀번호로 접근하면 성공" do
    get admin_wiki_path, headers: basic_auth(configured_password)
    expect(response).to have_http_status(:success)
  end

  it "소스코드에 비밀번호 폴백이 없다" do
    src = Rails.root.join("app/controllers/admin/wikis_controller.rb").read
    # ENV.fetch("KEY", "값") 형태의 2인자 폴백이 되살아나면 실패시킨다
    expect(src).not_to match(/ENV\.fetch\(\s*["']ADMIN_WIKI_PASSWORD["']\s*,/)
  end
end

require "rails_helper"

# /admin 좌측 메뉴 — 리소스명이 영문 그대로면 운영자가 무엇을 여는지 알기 어렵다.
# 메뉴 순서 제어(main_menu)는 avo-pro 전용이라 불가능하므로, 이름 한글화로만 가독성을 확보한다.
RSpec.describe "Admin 좌측 메뉴", type: :request do
  let(:admin) { create(:user, :admin) }
  before { sign_in admin }

  it "리소스명이 모두 한글로 보인다" do
    get "/admin/resources/case_studies"
    body = response.body

    %w[사례\ 콘텐츠 사례\ 미디어 사례\ 댓글 데모\ 신청 문의 회원].each do |label|
      expect(body).to include(label), "메뉴에 '#{label}' 이 없다"
    end
  end

  # Avo 는 번역 결과에 humanize 를 걸어 약어를 망가뜨린다 ("IR" → "Ir").
  # Download 리소스에서 self.name 을 직접 정의해 우회했다.
  it "IR 약어가 대문자로 유지된다" do
    get "/admin/resources/case_studies"
    expect(response.body).to include("IR 자료 신청")
    expect(response.body).not_to include("Ir 자료 신청")
  end

  it "영문 리소스명이 남아 있지 않다" do
    get "/admin/resources/case_studies"
    body = response.body
    # 메뉴 영역에 노출되던 기본 영문명
    expect(body).not_to include(">Contact inquiries<")
    expect(body).not_to include(">Demo requests<")
    expect(body).not_to include(">Downloads<")
  end

  describe "첫 화면" do
    # 기본값은 Avo 데모 페이지("Welcome to Avo" + 제품 홍보). 실제 업무 화면으로 보낸다.
    it "/admin 은 KPI 대시보드로 간다" do
      get "/admin"
      expect(response).to redirect_to("/admin/kpi")
    end

    it "Avo 데모 페이지가 노출되지 않는다" do
      get "/admin/kpi"
      expect(response.body).not_to include("Welcome to Avo")
    end
  end

  # main_menu 를 설정하면 OSS 판에서는 무시되고 경고 배너만 뜬다.
  it "Pro 라이선스 경고가 뜨지 않는다" do
    get "/admin/kpi"
    expect(response.body).not_to include("Pro license")
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end

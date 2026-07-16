require "rails_helper"

# 갤러리 상세 페이지가 익명 좋아요 중복 방지용으로 visitor 쿠키를 심는다.
# cookies.permanent 는 만료가 20년이라 처리방침의 "로그인에 필요한 쿠키만 사용" 과 충돌했다.
# 기능은 유지하되 수명을 30일로 줄이고 방침에 명시한다 (2026-07-16 결정).
RSpec.describe "갤러리 방문자 쿠키", type: :request do
  let!(:study) { CaseStudy.create!(slug: "cookie-case", title_ko: "쿠키 검증 사례", published: true) }

  def visitor_cookie_header
    response.headers["Set-Cookie"].to_s.lines.find { |l| l.start_with?("xim_visitor") }
  end

  it "좋아요를 누르면 visitor 쿠키가 발급된다" do
    post "/ko/cases/cookie-case/like"
    expect(visitor_cookie_header).to be_present
  end

  # 20년(cookies.permanent 기본값)은 좋아요 중복 방지에 과하다.
  it "visitor 쿠키 수명은 30일이다" do
    post "/ko/cases/cookie-case/like"
    header = visitor_cookie_header
    expect(header).to be_present

    expires = header[/expires=([^;]+)/, 1]
    expect(expires).to be_present
    expect(Time.parse(expires)).to be_within(2.days).of(CaseStudiesController::VISITOR_TOKEN_TTL.from_now)
  end

  it "쿠키에 개인을 식별할 정보가 담기지 않는다 (임의 UUID)" do
    post "/ko/cases/cookie-case/like"
    value = visitor_cookie_header[/xim_visitor=([^;]+)/, 1]
    expect(value).to match(/\A[0-9a-f-]{36}\z/)
  end

  # 방침에 적은 것과 코드가 어긋나면 안 된다 (제30조 제3항). — ISS-009/011 과 같은 맥락
  it "처리방침이 이 쿠키를 명시한다" do
    get "/ko/privacy"
    expect(response.body).to include("좋아요")
    expect(response.body).to include("30일")
  end

  it "영문 처리방침에도 명시된다" do
    get "/en/privacy"
    expect(response.body).to match(/like/i)
    expect(response.body).to include("30 days")
  end
end

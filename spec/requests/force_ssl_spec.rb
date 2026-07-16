require "rails_helper"

# ISS-005 — 프로덕션 세션 쿠키에 secure 플래그가 없어, nginx 가 HTTPS 로 리다이렉트하기 전
# 첫 평문 요청에 세션이 실려 나갔다.
#
# force_ssl 은 production 에서만 켜지고 test 환경에는 미들웨어가 적용되지 않는다.
# production 환경을 실제로 부팅해서 설정값을 확인한다 (느리지만 확실하다).
RSpec.describe "프로덕션 SSL 설정" do
  before(:all) do
    @cfg = JSON.parse(
      `RAILS_ENV=production SECRET_KEY_BASE=dummy bin/rails runner #{Shellwords.escape(PROBE)} 2>/dev/null`.lines.last.to_s,
      symbolize_names: true
    )
  end

  PROBE = <<~RUBY.freeze
    require "ostruct"
    c = Rails.application.config
    ex = c.ssl_options.dig(:redirect, :exclude)
    puts({
      force_ssl:     c.force_ssl,
      assume_ssl:    c.assume_ssl,
      up_excluded:   ex ? ex.call(OpenStruct.new(path: "/up")) : nil,
      page_excluded: ex ? ex.call(OpenStruct.new(path: "/ko")) : nil
    }.to_json)
  RUBY

  it "force_ssl 이 켜져 있다 — 세션 쿠키에 secure 플래그가 붙는다" do
    expect(@cfg[:force_ssl]).to be(true)
  end

  # TLS 는 외부 nginx 가 종단하고 앱은 뒤에서 평문 HTTP 로 받는다.
  # assume_ssl 없이 force_ssl 만 켜면 무한 리다이렉트 루프에 빠진다.
  it "assume_ssl 이 짝으로 켜져 있다" do
    expect(@cfg[:assume_ssl]).to be(true)
  end

  # kamal-proxy 헬스체크는 컨테이너 내부에서 평문으로 들어온다.
  # 제외하지 않으면 301 을 받아 배포가 실패한다.
  it "헬스체크(/up)는 SSL 리다이렉트에서 제외된다" do
    expect(@cfg[:up_excluded]).to be(true)
  end

  it "일반 페이지는 제외되지 않는다" do
    expect(@cfg[:page_excluded]).to be(false)
  end
end

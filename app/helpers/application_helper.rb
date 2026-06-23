module ApplicationHelper
  # XimTier SaaS 분석 게이트웨이 주소. 로그인 연동용.
  # 환경변수 XIMTIER_SAAS_URL 우선, 없으면 로컬 개발 기본값.
  def ximtier_saas_login_url
    base = ENV.fetch("XIMTIER_SAAS_URL", "http://localhost:3000").chomp("/")
    "#{base}/login?lang=#{I18n.locale}"
  end
end

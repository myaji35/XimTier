module ApplicationHelper
  # XimTier SaaS 분석 게이트웨이 주소.
  # 환경변수 XIMTIER_SAAS_URL 우선, 없으면 로컬 개발 기본값.
  def ximtier_saas_url
    ENV.fetch("XIMTIER_SAAS_URL", "http://localhost:3000").chomp("/")
  end

  # XimTier SaaS 로그인 연동 주소.
  def ximtier_saas_login_url
    "#{ximtier_saas_url}/login?lang=#{I18n.locale}"
  end
end

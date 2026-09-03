module ApplicationHelper
  # Meta 픽셀 ID 목록. 콤마로 여러 개 지정할 수 있다.
  def meta_pixel_ids
    ENV.fetch("META_PIXEL_ID", "").split(",").map(&:strip).select { |id| id.match?(/\A\d+\z/) }.uniq
  end

  # XimTier SaaS 분석 게이트웨이 주소.
  # 환경변수 XIMTIER_SAAS_URL 우선, 없으면 로컬 개발 기본값.
  def ximtier_saas_url
    ENV.fetch("XIMTIER_SAAS_URL", "http://localhost:3000").chomp("/")
  end

  # XimTier SaaS 로그인 연동 주소.
  def ximtier_saas_login_url
    "#{ximtier_saas_url}/login?lang=#{I18n.locale}"
  end

  # 메일 본문에서 사용할 서명된 수신거부 절대 주소.
  def unsubscribe_url_for(email)
    token = Rails.application.message_verifier(:email_optout).generate(EmailOptOut.normalize(email))
    unsubscribe_url(token: token, locale: I18n.locale)
  end
end

class DownloadMailer < ApplicationMailer
  def link(download)
    @download = download
    host = ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io")
    @download_url = ir_download_url(token: download.download_token, host: host)
    # 시장($81B TAM) 근거는 투자자용 자료다. 고객용 헤더 메뉴에는 노출하지 않고
    # IR 자료를 받는 이 경로로 안내한다 (2026-07-16 결정).
    @market_url = market_url(locale: download.locale, host: host)
    I18n.with_locale(download.locale) do
      mail(to: download.email, subject: t("mailer.download.subject"))
    end
  end

  # IR 신청이 오면 대표님께 알린다. 자료는 이미 자동 발송된 뒤다 —
  # 이 메일의 목적은 "누가 받아갔는지" 를 놓치지 않고 후속 연락 타이밍을 잡는 것이다.
  # 데모 신청·문의는 알림이 있는데 IR 만 없었다.
  def admin_notification(download)
    @download = download
    @classification = InvestorClassifier.call(download.email)
    @admin_url = "https://#{ENV.fetch('APP_HOST', 'ximtier.com')}/admin/resources/downloads/#{download.id}"

    # 제목만 보고도 우선순위를 판단할 수 있어야 한다.
    I18n.with_locale(:ko) do
      mail(
        to: admin_recipients,
        subject: "[XimTier] #{@classification.label} IR 신청 — #{download.name} (#{download.company})"
      )
    end
  end
end

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
end

class DownloadMailer < ApplicationMailer
  def link(download)
    @download = download
    @download_url = ir_download_url(token: download.download_token, host: ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io"))
    I18n.with_locale(download.locale) do
      mail(to: download.email, subject: t("mailer.download.subject"))
    end
  end
end

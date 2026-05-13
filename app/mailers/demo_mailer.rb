class DemoMailer < ApplicationMailer
  def welcome(user, password)
    @user = user
    @password = password
    @login_url = new_user_session_url(host: ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io"))
    I18n.with_locale(user.locale) do
      mail(to: user.email, subject: t("mailer.demo.welcome.subject"))
    end
  end

  def received(demo_request)
    @demo_request = demo_request
    @user = demo_request.user
    @dashboard_url = dashboard_url(host: ENV.fetch("APP_HOST", "ximtier.158.247.235.31.nip.io"), locale: demo_request.locale)
    I18n.with_locale(demo_request.locale) do
      mail(to: @user.email, subject: t("mailer.demo.received.subject"))
    end
  end

  def admin_notification(demo_request)
    @demo_request = demo_request
    @user = demo_request.user
    mail(
      to: ENV.fetch("ADMIN_EMAIL", "admin@ximtier.io"),
      subject: "[XimTier] 새 데모 신청 — #{@user.display_name} (#{@user.company})"
    )
  end
end

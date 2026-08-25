class DemoMailer < ApplicationMailer
  def received(demo_request)
    @demo_request = demo_request
    @user = demo_request.user
    I18n.with_locale(demo_request.locale) do
      mail(to: @user.email, subject: t("mailer.demo.received.subject"))
    end
  end

  def admin_notification(demo_request)
    @demo_request = demo_request
    @user = demo_request.user
    mail(
      to: admin_recipients,
      subject: "[XimTier] 새 데모 신청 — #{@user.display_name} (#{@user.company})"
    )
  end

  def scheduled(demo_request)
    @demo_request = demo_request
    @user = demo_request.user
    I18n.with_locale(demo_request.locale) do
      mail(to: @user.email, subject: t("mailer.demo.scheduled.subject"))
    end
  end
end

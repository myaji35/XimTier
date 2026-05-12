class ContactMailer < ApplicationMailer
  def auto_reply(inquiry)
    @inquiry = inquiry
    I18n.with_locale(inquiry.locale) do
      mail(to: inquiry.email, subject: t("mailer.contact.auto_reply.subject"))
    end
  end

  def admin_notification(inquiry)
    @inquiry = inquiry
    mail(
      to: ENV.fetch("ADMIN_EMAIL", "admin@ximtier.io"),
      subject: "[XimTier] 새 문의 — #{inquiry.name} (#{inquiry.company})"
    )
  end
end

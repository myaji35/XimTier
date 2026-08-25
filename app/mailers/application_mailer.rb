class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "XimTier <hello@ximtier.com>"),
          reply_to: ENV.fetch("MAIL_REPLY_TO", "contact@ximtier.com")
  layout "mailer"

  protected

  def admin_recipients
    ENV.fetch("ADMIN_EMAIL", "contact@ximtier.com").split(",").map(&:strip).reject(&:empty?)
  end
end

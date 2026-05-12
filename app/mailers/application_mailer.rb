class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "XimTier <no-reply@ximtier.io>"),
          reply_to: ENV.fetch("MAIL_REPLY_TO", "contact@ximtier.io")
  layout "mailer"
end

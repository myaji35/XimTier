class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "XimTier <hello@ximtier.com>"),
          reply_to: ENV.fetch("MAIL_REPLY_TO", "hello@ximtier.com")
  layout "mailer"
end

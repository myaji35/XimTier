class FailedJobsMailer < ApplicationMailer
  def alert(count:, summary:)
    mail(
      to: ENV.fetch("ADMIN_EMAIL").split(",").map(&:strip).reject(&:empty?),
      subject: "[XimTier] Solid Queue 실패 잡 #{count}건 감지",
      body: "Solid Queue에 실패한 잡이 #{count}건 있습니다.\n\n최근 실패 최대 10건:\n#{summary}"
    )
  end
end

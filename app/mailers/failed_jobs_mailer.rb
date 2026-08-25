class FailedJobsMailer < ApplicationMailer
  def alert(new_count:, total_count:, summary:)
    mail(
      to: admin_recipients,
      subject: "[XimTier] Solid Queue 신규 실패 잡 #{new_count}건 감지",
      body: "Solid Queue에 신규 실패 잡이 #{new_count}건 있습니다.\n" \
            "누적 실패 잡: #{total_count}건\n\n신규 실패 최대 10건:\n#{summary}"
    )
  end
end

class DeployWatchdogMailer < ApplicationMailer
  def stalled(expected_sha:, actual_sha:, duration_seconds:)
    @expected_sha = expected_sha
    @actual_sha = actual_sha
    @duration = duration_text(duration_seconds.to_i)

    mail(
      to: ENV.fetch("ADMIN_EMAIL", "myaji35@ximtier.com").split(",").map(&:strip).reject(&:empty?),
      subject: "[XimTier] 프로덕션 배포 정체 — #{actual_sha.first(7)} → #{expected_sha.first(7)}"
    )
  end

  private

  def duration_text(seconds)
    hours, remainder = seconds.divmod(1.hour)
    minutes = remainder / 1.minute
    "#{hours}시간 #{minutes}분"
  end
end

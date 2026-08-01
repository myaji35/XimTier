class MonitorFailedJobsJob < ApplicationJob
  queue_as :default

  def perform
    failed_executions = SolidQueue::FailedExecution.includes(:job).order(created_at: :desc)
    count = failed_executions.count
    return if count.zero?

    summary = failure_summary(failed_executions.limit(10))
    Rails.logger.error("[MonitorFailedJobs] failed_executions=#{count}\n#{summary}")
    notify_admin(count, summary) if ENV["ADMIN_EMAIL"].present?
  end

  private

  def failure_summary(failed_executions)
    failed_executions.map do |execution|
      "- #{execution.job.class_name}: #{execution.exception_class}: #{execution.message}"
    end.join("\n")
  end

  def notify_admin(count, summary)
    FailedJobsMailer.alert(count:, summary:).deliver_now
  rescue StandardError => error
    Rails.logger.error(
      "[MonitorFailedJobs] admin notification failed: #{error.class}: #{error.message}"
    )
  end
end

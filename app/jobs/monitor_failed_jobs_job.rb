class MonitorFailedJobsJob < ApplicationJob
  queue_as :default

  LAST_NOTIFIED_ID_CACHE_KEY = "monitor_failed_jobs:last_notified_id"

  def perform
    failed_executions = SolidQueue::FailedExecution.includes(:job).order(created_at: :desc)
    total_count = failed_executions.count
    last_notified_id = Rails.cache.read(LAST_NOTIFIED_ID_CACHE_KEY).to_i
    new_failed_executions = failed_executions.where("solid_queue_failed_executions.id > ?", last_notified_id)
    new_count = new_failed_executions.count

    if new_count.zero?
      Rails.logger.error("[MonitorFailedJobs] new_failed_executions=0 total_failed_executions=#{total_count}")
      return
    end

    latest_new_id = new_failed_executions.maximum(:id)
    monitor_failures, job_failures = new_failed_executions.partition do |execution|
      execution.job.class_name == self.class.name
    end
    summary = failure_summary(monitor_failures, job_failures.first(10))
    Rails.logger.error(
      "[MonitorFailedJobs] new_failed_executions=#{new_count} " \
      "total_failed_executions=#{total_count}\n#{summary}"
    )

    if job_failures.empty?
      Rails.cache.write(LAST_NOTIFIED_ID_CACHE_KEY, latest_new_id)
      return
    end

    return unless ENV["ADMIN_EMAIL"].present?

    notify_admin(new_count, total_count, summary)
    Rails.cache.write(LAST_NOTIFIED_ID_CACHE_KEY, latest_new_id)
  end

  private

  def failure_summary(monitor_failures, job_failures)
    lines = ["감시 잡 자체 실패: #{monitor_failures.count}건"]
    lines.concat(job_failures.map do |execution|
      "- #{execution.job.class_name}: #{execution.exception_class}: #{execution.message}"
    end)
    lines.join("\n")
  end

  def notify_admin(new_count, total_count, summary)
    FailedJobsMailer.alert(new_count:, total_count:, summary:).deliver_now
  end
end

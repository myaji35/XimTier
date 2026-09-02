class GoogleSheetExportJob < ApplicationJob
  queue_as :default

  retry_on GoogleSheetExporter::TransientError,
           Net::ReadTimeout,
           Net::OpenTimeout,
           Timeout::Error,
           wait: :polynomially_longer,
           attempts: 5 do |job, error|
    job.send(:notify_final_failure, error)
  end

  discard_on ActiveRecord::RecordNotFound do |job, error|
    Rails.logger.warn(
      "[GoogleSheetExportJob] discarded: arguments=#{job.arguments.inspect} " \
      "error=#{error.class}: #{error.message}"
    )
  end

  def perform(record_type, record_id)
    case record_type
    when "contact"
      inquiry = ContactInquiry.find(record_id)
      GoogleSheetExporter.export_contact(inquiry)
    when "demo"
      demo_request = DemoRequest.find(record_id)
      GoogleSheetExporter.export_demo(demo_request)
    end
  end

  private

  def notify_final_failure(error)
    summary = "- #{self.class.name}: #{error.class}: #{error.message} " \
              "arguments=#{arguments.inspect}"
    Rails.logger.error("[GoogleSheetExportJob] retries exhausted\n#{summary}")
    return unless ENV["ADMIN_EMAIL"].present?

    FailedJobsMailer.alert(new_count: 1, total_count: 1, summary:).deliver_now
  rescue StandardError => notification_error
    Rails.logger.error(
      "[GoogleSheetExportJob] admin notification failed: " \
      "#{notification_error.class}: #{notification_error.message}"
    )
  end
end

class GoogleSheetExportJob < ApplicationJob
  queue_as :default

  def perform(record_type, record_id)
    case record_type
    when "contact"
      inquiry = ContactInquiry.find_by(id: record_id)
      return unless inquiry

      GoogleSheetExporter.export_contact(inquiry)
    when "demo"
      demo_request = DemoRequest.find_by(id: record_id)
      return unless demo_request

      GoogleSheetExporter.export_demo(demo_request)
    end
  rescue StandardError => e
    Rails.logger.warn("[GoogleSheetExportJob] export failed: #{e.class}: #{e.message}")
  end
end

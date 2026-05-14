class SlackContactNotificationJob < ApplicationJob
  queue_as :default

  def perform(inquiry_id)
    inquiry = ContactInquiry.find_by(id: inquiry_id)
    return unless inquiry

    SlackNotifier.notify_contact(inquiry)
  end
end

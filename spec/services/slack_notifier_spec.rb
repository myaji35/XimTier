require "rails_helper"

RSpec.describe SlackNotifier do
  let(:inquiry) do
    ContactInquiry.create!(
      name: "테스트", email: "t@t.com",
      company: "테스트사", industry: "manufacturing",
      message: "메시지", locale: "ko"
    )
  end

  around do |example|
    original = { contact: ENV["SLACK_CONTACT_WEBHOOK_URL"], generic: ENV["SLACK_WEBHOOK_URL"] }
    example.run
    ENV["SLACK_CONTACT_WEBHOOK_URL"] = original[:contact]
    ENV["SLACK_WEBHOOK_URL"]         = original[:generic]
  end

  describe ".notify_contact" do
    it "webhook URL이 없으면 false 반환 (no-op)" do
      ENV["SLACK_CONTACT_WEBHOOK_URL"] = nil
      ENV["SLACK_WEBHOOK_URL"]         = nil
      expect(described_class.notify_contact(inquiry)).to be false
    end

    it "webhook URL이 있으면 POST 후 true 반환" do
      ENV["SLACK_CONTACT_WEBHOOK_URL"] = "https://hooks.slack.com/services/T/B/x"
      allow(described_class).to receive(:post_json).and_return(true)
      expect(described_class.notify_contact(inquiry)).to be true
      expect(described_class).to have_received(:post_json).with(
        "https://hooks.slack.com/services/T/B/x",
        hash_including(:text, :blocks)
      )
    end
  end
end

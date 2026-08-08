require "rails_helper"

RSpec.describe DeployWatchdogMailer do
  describe "#stalled" do
    subject(:mail) do
      described_class.stalled(
        expected_sha: expected_sha,
        actual_sha: actual_sha,
        duration_seconds: 9_000
      )
    end

    let(:expected_sha) { "a" * 40 }
    let(:actual_sha) { "b" * 40 }

    around do |example|
      original_admin_email = ENV["ADMIN_EMAIL"]
      ENV["ADMIN_EMAIL"] = "myaji35@gmail.com"
      example.run
    ensure
      ENV["ADMIN_EMAIL"] = original_admin_email
    end

    it "ADMIN_EMAIL 주소로 보낸다" do
      expect(mail.to).to eq([ "myaji35@gmail.com" ])
    end

    context "ADMIN_EMAIL에 여러 주소가 설정된 경우" do
      around do |example|
        original_admin_email = ENV["ADMIN_EMAIL"]
        ENV["ADMIN_EMAIL"] = "a@example.com, b@example.com"
        example.run
      ensure
        ENV["ADMIN_EMAIL"] = original_admin_email
      end

      it "콤마로 구분한 관리자 주소 모두에 보낸다" do
        expect_any_instance_of(described_class).to receive(:mail).with(
          hash_including(to: [ "a@example.com", "b@example.com" ])
        ).and_call_original

        expect(mail.to).to eq([ "a@example.com", "b@example.com" ])
      end
    end

    it "기대 SHA와 실제 SHA를 본문에 담는다" do
      expect(mail.body.encoded).to include(expected_sha, actual_sha)
    end
  end
end

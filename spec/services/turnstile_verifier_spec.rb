require "rails_helper"

RSpec.describe TurnstileVerifier do
  around do |example|
    original = { secret: ENV["TURNSTILE_SECRET_KEY"], site: ENV["TURNSTILE_SITE_KEY"] }
    example.run
    ENV["TURNSTILE_SECRET_KEY"] = original[:secret]
    ENV["TURNSTILE_SITE_KEY"]   = original[:site]
  end

  describe ".enabled?" do
    it "secret + site key 둘 다 있을 때만 true" do
      ENV["TURNSTILE_SITE_KEY"]   = "site"
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      expect(described_class.enabled?).to be true

      ENV["TURNSTILE_SITE_KEY"] = nil
      expect(described_class.enabled?).to be false
    end
  end

  describe ".verify" do
    it "secret 미설정이면 통과 처리 (개발 환경)" do
      ENV["TURNSTILE_SECRET_KEY"] = nil
      expect(described_class.verify("any-token")).to be true
    end

    it "secret 있지만 token 비어있으면 false" do
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      expect(described_class.verify("")).to be false
      expect(described_class.verify(nil)).to be false
    end

    it "Cloudflare 응답이 success: true면 true" do
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      fake_res = instance_double(Net::HTTPSuccess, body: '{"success":true}')
      allow(fake_res).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(Net::HTTP).to receive(:post_form).and_return(fake_res)

      expect(described_class.verify("token")).to be true
    end

    it "Cloudflare 응답이 success: false면 false" do
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      fake_res = instance_double(Net::HTTPSuccess, body: '{"success":false,"error-codes":["invalid-input-response"]}')
      allow(fake_res).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(Net::HTTP).to receive(:post_form).and_return(fake_res)

      expect(described_class.verify("token")).to be false
    end

    it "네트워크 에러 시 false (fail closed)" do
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      allow(Net::HTTP).to receive(:post_form).and_raise(SocketError)
      expect(described_class.verify("token")).to be false
    end
  end
end

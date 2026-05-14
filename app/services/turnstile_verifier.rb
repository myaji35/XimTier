require "net/http"
require "uri"
require "json"

class TurnstileVerifier
  ENDPOINT = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify").freeze

  def self.verify(token, remote_ip: nil)
    secret = ENV["TURNSTILE_SECRET_KEY"].to_s

    # Disabled when secret not configured (local/dev) — treat as passing
    # so the contact flow remains usable without Cloudflare credentials.
    return true if secret.blank?
    return false if token.blank?

    body = { secret: secret, response: token }
    body[:remoteip] = remote_ip if remote_ip.present?

    res = Net::HTTP.post_form(ENDPOINT, body)
    return false unless res.is_a?(Net::HTTPSuccess)

    parsed = JSON.parse(res.body)
    !!parsed["success"]
  rescue StandardError => e
    Rails.logger.warn("[TurnstileVerifier] verify failed: #{e.class}: #{e.message}")
    false
  end

  def self.enabled?
    ENV["TURNSTILE_SITE_KEY"].present? && ENV["TURNSTILE_SECRET_KEY"].present?
  end

  def self.site_key
    ENV["TURNSTILE_SITE_KEY"].to_s
  end
end

require "net/http"
require "uri"
require "json"

class TurnstileVerifier
  ENDPOINT = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify").freeze

  def self.verify(token, remote_ip: nil)
    secret = secret_key.to_s

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
    site_key_value.present? && secret_key.present?
  end

  def self.site_key
    site_key_value.to_s
  end

  def self.secret_key
    ENV["CF_TURNSTILE_SECRET_KEY"].presence || ENV["TURNSTILE_SECRET_KEY"]
  end
  private_class_method :secret_key

  def self.site_key_value
    ENV["CF_TURNSTILE_SITE_KEY"].presence || ENV["TURNSTILE_SITE_KEY"]
  end
  private_class_method :site_key_value
end

require "net/http"
require "uri"
require "json"

class SlackNotifier
  def self.notify_contact(inquiry)
    webhook = ENV["SLACK_CONTACT_WEBHOOK_URL"].presence || ENV["SLACK_WEBHOOK_URL"].to_s
    return false if webhook.blank?

    payload = {
      text: "📩 새 문의가 도착했습니다",
      blocks: [
        { type: "header", text: { type: "plain_text", text: "📩 #{inquiry.name} (#{inquiry.company.presence || '-'})" } },
        { type: "section", fields: [
          { type: "mrkdwn", text: "*이메일:*\n#{inquiry.email}" },
          { type: "mrkdwn", text: "*산업:*\n#{inquiry.industry}" },
          { type: "mrkdwn", text: "*Locale:*\n#{inquiry.locale}" },
          { type: "mrkdwn", text: "*Source:*\n#{inquiry.source.presence || '-'}" }
        ] },
        { type: "section", text: { type: "mrkdwn", text: "*메시지:*\n```#{inquiry.message.to_s.truncate(1500)}```" } }
      ]
    }

    post_json(webhook, payload)
  end

  def self.post_json(url, payload)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 3
    http.read_timeout = 5

    req = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
    req.body = payload.to_json

    res = http.request(req)
    res.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    Rails.logger.warn("[SlackNotifier] post failed: #{e.class}: #{e.message}")
    false
  end
end

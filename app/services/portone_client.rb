require "net/http"
require "json"
require "cgi"

class PortoneClient
  API_BASE = "https://api.portone.io"

  def self.store_id
    ENV["PORTONE_STORE_ID"]
  end

  def self.api_secret
    ENV["PORTONE_API_SECRET"]
  end
  private_class_method :api_secret

  def self.channel_key
    ENV["PORTONE_CHANNEL_KEY"]
  end

  def self.enabled?
    store_id.present? && api_secret.present?
  end

  def self.fetch_payment(tx_id)
    uri = URI("#{API_BASE}/payments/#{CGI.escape(tx_id)}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "PortOne #{api_secret}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("[PortoneClient] fetch failed: HTTP #{response.code}: #{response.body}")
      return nil
    end

    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.warn("[PortoneClient] fetch failed: #{e.class}: #{e.message}")
    nil
  end

  def self.verify!(payment)
    return [false, "tx_id 없음", nil] if payment.portone_tx_id.blank?

    result = fetch_payment(payment.portone_tx_id)
    return [false, "조회 실패", nil] if result.nil?

    status = result["status"]
    return [false, "미결제 상태: #{status}", result] unless status == "PAID"

    actual = result.dig("amount", "total")
    actual_integer = Integer(actual, exception: false)
    unless actual_integer == payment.amount.to_i
      return [false, "금액 불일치: 기대 #{payment.amount}, 실제 #{actual}", result]
    end

    return [false, "주문번호 불일치", result] unless result["paymentId"] == payment.payment_id

    [true, nil, result]
  end

  # TODO(ISS-238): 포트원 웹훅 서명 검증. 실제 시크릿 수령 후 구현한다.
  # 미구현 상태에서 true 를 반환하면 위조 웹훅이 통과하므로 false 를 반환한다.
  def self.verify_webhook_signature(_body, _headers)
    false
  end
end

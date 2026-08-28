require "base64"
require "json"
require "net/http"
require "openssl"
require "uri"

class GoogleSheetExporter
  TOKEN_URL = "https://oauth2.googleapis.com/token"
  SHEETS_SCOPE = "https://www.googleapis.com/auth/spreadsheets"

  # 내부 계정 — 실제 리드가 아니므로 '테스트' 로 태깅한다.
  # 추가 주소는 ENV["SHEET_TEST_EMAILS"] 에 콤마로 넣는다.
  INTERNAL_EMAILS = %w[
    smartician@naver.com
    myaji35@gmail.com
  ].freeze

  def self.enabled?
    ENV["GOOGLE_SHEETS_SA_EMAIL"].present? &&
      ENV["GOOGLE_SHEETS_SA_PRIVATE_KEY"].present? &&
      ENV["GOOGLE_SHEETS_ID"].present?
  end

  def self.append_row(values)
    return false unless enabled?

    token = access_token
    unless token
      Rails.logger.warn("[GoogleSheetExporter] append skipped: access token unavailable")
      return false
    end

    spreadsheet_id = URI.encode_www_form_component(ENV.fetch("GOOGLE_SHEETS_ID"))
    range = URI.encode_www_form_component(ENV["GOOGLE_SHEETS_RANGE"].presence || "A:Z")
    uri = URI("https://sheets.googleapis.com/v4/spreadsheets/#{spreadsheet_id}/values/#{range}:append")
    uri.query = URI.encode_www_form(
      valueInputOption: "USER_ENTERED",
      insertDataOption: "INSERT_ROWS"
    )

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 5

    request = Net::HTTP::Post.new(
      uri.request_uri,
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    )
    request.body = { values: [values] }.to_json

    response = http.request(request)
    return true if response.is_a?(Net::HTTPSuccess)

    Rails.logger.warn(
      "[GoogleSheetExporter] append failed: status=#{response.code} body=#{response.body}"
    )
    false
  rescue StandardError => e
    Rails.logger.warn("[GoogleSheetExporter] append failed: #{e.class}: #{e.message}")
    false
  end

  def self.export_contact(inquiry)
    append_row([
      Time.current.strftime("%Y-%m-%d %H:%M"),
      tag_for(inquiry.email, "문의"),
      inquiry.name,
      inquiry.email,
      inquiry.company.presence || "",
      inquiry.industry.presence || "",
      inquiry.locale.to_s,
      inquiry.source.presence || "",
      inquiry.message.to_s.gsub(/\s+/, " ").truncate(500)
    ])
  end

  def self.export_demo(demo_request)
    append_row([
      Time.current.strftime("%Y-%m-%d %H:%M"),
      tag_for(demo_request.user&.email, "데모"),
      demo_request.user&.name.to_s,
      demo_request.user&.email.to_s,
      demo_request.user&.company.to_s,
      demo_request.user&.industry.to_s,
      demo_request.locale.to_s,
      demo_request.source.presence || "",
      demo_request.data_description.to_s.gsub(/\s+/, " ").truncate(500)
    ])
  end

  def self.access_token
    now = Time.now.to_i
    header = { alg: "RS256", typ: "JWT" }
    claims = {
      iss: ENV.fetch("GOOGLE_SHEETS_SA_EMAIL"),
      scope: SHEETS_SCOPE,
      aud: TOKEN_URL,
      iat: now,
      exp: now + 3600
    }

    signing_input = [header, claims].map { |part| base64url(part.to_json) }.join(".")
    private_key = normalized_private_key
    signature = OpenSSL::PKey::RSA.new(private_key).sign(OpenSSL::Digest::SHA256.new, signing_input)
    assertion = "#{signing_input}.#{base64url(signature)}"

    uri = URI(TOKEN_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 5

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: assertion
    )

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn(
        "[GoogleSheetExporter] token request failed: status=#{response.code} body=#{response.body}"
      )
      return nil
    end

    JSON.parse(response.body)["access_token"].presence.tap do |token|
      Rails.logger.warn("[GoogleSheetExporter] token response missing access_token") unless token
    end
  rescue StandardError => e
    Rails.logger.warn("[GoogleSheetExporter] token request failed: #{e.class}: #{e.message}")
    nil
  end

  def self.base64url(value)
    Base64.urlsafe_encode64(value, padding: false)
  end

  # SA 개인키는 주입 경로에 따라 형태가 제각각이다.
  # ① 실제 개행 포함(정상) ② \n 리터럴(이스케이프) ③ 개행이 통째로 사라진 한 줄(실측 사고)
  # 어떤 형태로 들어와도 유효한 PEM 으로 복원한다.
  def self.normalized_private_key
    raw = ENV.fetch("GOOGLE_SHEETS_SA_PRIVATE_KEY", "").to_s
    key = raw.gsub("\\n", "\n")
    return key if key.include?("\n")

    # 개행이 전부 사라진 경우: 헤더/푸터를 떼고 본문을 64자씩 재조립한다
    m = key.match(/-----BEGIN ([A-Z ]+)-----(.*)-----END \1-----/m)
    return key unless m

    label = m[1]
    body = m[2].gsub(/\s+/, "")
    "-----BEGIN #{label}-----\n#{body.scan(/.{1,64}/).join("\n")}\n-----END #{label}-----\n"
  end

  def self.internal_email?(email)
    normalized = email.to_s.strip.downcase
    return false if normalized.blank?

    extra = ENV["SHEET_TEST_EMAILS"].to_s.split(",").map { |e| e.strip.downcase }.reject(&:empty?)
    (INTERNAL_EMAILS + extra).include?(normalized)
  end

  def self.tag_for(email, default_tag)
    internal_email?(email) ? "테스트" : default_tag
  end

  private_class_method :access_token, :base64url, :normalized_private_key, :internal_email?, :tag_for
end

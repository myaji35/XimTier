class SpamFilter
  URL_PATTERN = %r{https?://}i
  SPAM_KEYWORDS = /\b(?:jackpot|casino|viagra|crypto\s+pump|seo\s+backlinks?|backlinks|rank\s+higher|buy\s+followers)\b/i
  COMPANY_DOMAINS = {
    "google" => %w[google.com],
    "facebook" => %w[facebook.com meta.com],
    "amazon" => %w[amazon.com],
    "apple" => %w[apple.com],
    "microsoft" => %w[microsoft.com]
  }.freeze

  def self.spam?(message:, name:, company:, email:)
    message = message.to_s
    name = name.to_s

    message.scan(URL_PATTERN).size >= 2 ||
      message.match?(SPAM_KEYWORDS) ||
      name.match?(SPAM_KEYWORDS) ||
      name.match?(URL_PATTERN) ||
      company_email_mismatch?(company, email)
  end

  def self.company_email_mismatch?(company, email)
    allowed_domains = COMPANY_DOMAINS[company.to_s.strip.downcase]
    return false unless allowed_domains

    email_domain = email.to_s.split("@", 2).last.to_s.downcase
    allowed_domains.none? { |domain| email_domain == domain || email_domain.end_with?(".#{domain}") }
  end
  private_class_method :company_email_mismatch?
end

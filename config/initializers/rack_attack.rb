# Rack::Attack — XimTier 스팸/abuse 차단
# 안전 우선, false-positive 최소화. throttle 우선, blocklist는 명확한 어뷰즈에만.

Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

# === Throttles ===

# 폼 제출 — IP당 분당 5회
Rack::Attack.throttle("forms/ip", limit: 5, period: 1.minute) do |req|
  if req.post? && (req.path.end_with?("/contact") || req.path.end_with?("/company/investors") || req.path.end_with?("/demo"))
    req.ip
  end
end

# 전체 요청 — IP당 5분 1000회 (정상 트래픽은 충분)
Rack::Attack.throttle("req/ip", limit: 1000, period: 5.minutes) do |req|
  req.ip unless req.path.start_with?("/up", "/assets")
end

# Devise sign_in/up — IP당 분당 10회
Rack::Attack.throttle("auth/ip", limit: 10, period: 1.minute) do |req|
  if req.post? && req.path.start_with?("/users/")
    req.ip
  end
end

# === Blocklist (명확한 어뷰즈) ===

# 알려진 봇 user agent
Rack::Attack.blocklist("bad-bots") do |req|
  req.user_agent.to_s.match?(/sqlmap|nmap|nikto|masscan|fuzz|wpscan/i)
end

# === Response ===

Rack::Attack.throttled_responder = lambda do |request|
  retry_after = (request.env["rack.attack.match_data"] || {})[:period]
  [
    429,
    { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
    ["Throttled. Please retry shortly.\n"]
  ]
end

# Logging
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  request = payload[:request]
  Rails.logger.warn("[Rack::Attack] throttled #{request.env['rack.attack.matched']} ip=#{request.ip} path=#{request.path}")
end

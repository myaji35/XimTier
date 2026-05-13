# Sentry — ENV SENTRY_DSN 설정 시만 활성
# .kamal/secrets 또는 .env에 SENTRY_DSN=https://... 입력 후 재배포.

if ENV["SENTRY_DSN"].present?
  require "sentry-ruby"
  require "sentry-rails"

  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = Rails.env
    config.release = ENV["KAMAL_VERSION"] || `git rev-parse --short HEAD 2>/dev/null`.strip.presence

    # 성능 추적은 운영 안정화 후 점진 활성
    config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_RATE", "0.0").to_f
    config.profiles_sample_rate = ENV.fetch("SENTRY_PROFILES_RATE", "0.0").to_f

    # PII 제외 (Devise 이메일 등 노출 방지)
    config.send_default_pii = false

    # Test/dev 환경은 비활성
    config.enabled_environments = %w[production staging]

    # 노이즈 필터링
    config.excluded_exceptions += %w[
      ActionController::RoutingError
      ActiveRecord::RecordNotFound
      Devise::Strategies::Authenticatable::AuthenticationError
    ]
  end
end

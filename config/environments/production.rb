require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # 이미지 URL 을 서명된 임시 링크로 302 리다이렉트하지 않고 앱이 직접 서빙한다.
  # 기본값(:redirect)은 Cache-Control: max-age=300, private 인 302 를 거치는데,
  # 5분이 지나면 링크가 만료되어 캐시된 페이지에서 썸네일이 깨진다
  # ("보였다 안 보였다" 하는 증상의 원인 — 2026-07-20).
  # :proxy 는 리다이렉트 없이 이미지를 그대로 내보내므로 만료가 없고 캐시도 오래 간다.
  config.active_storage.resolve_model_to_route = :rails_storage_proxy

  # TLS는 외부 nginx(+certbot)가 종단한다. 앱은 그 뒤에서 평문 HTTP로 받으므로
  # assume_ssl 없이 force_ssl만 켜면 리다이렉트 루프에 빠진다. 반드시 짝으로 둘 것. — ISS-005
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # HTTP→HTTPS 리다이렉트는 이미 nginx가 한다. 여기서 얻는 실익은 세션 쿠키의 secure 플래그와
  # HSTS 헤더다 — 그전까지 세션 쿠키에 secure가 없어 첫 평문 요청에 실려 나갔다.
  config.force_ssl = true

  # kamal-proxy 헬스체크(/up)는 컨테이너 내부에서 평문 HTTP로 들어온다.
  # 제외하지 않으면 헬스체크가 301을 받아 배포가 실패한다.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Action Mailer — generic SMTP (Postmark/Mailgun/SES/SendGrid plug-in)
  # 활성 조건: ENV SMTP_HOST + SMTP_USERNAME + SMTP_PASSWORD 모두 존재
  # 없으면 :test로 폴백 → 메일 발송 시도 시 deliveries 배열에만 저장 (404 X)
  if ENV["SMTP_HOST"].present? && ENV["SMTP_USERNAME"].present? && ENV["SMTP_PASSWORD"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV["SMTP_HOST"],
      port:                 ENV.fetch("SMTP_PORT", "587").to_i,
      domain:               ENV.fetch("SMTP_DOMAIN", ENV.fetch("APP_HOST", "ximtier.com")),
      user_name:            ENV["SMTP_USERNAME"],
      password:             ENV["SMTP_PASSWORD"],
      authentication:       (ENV["SMTP_AUTH"] || "plain").to_sym,
      enable_starttls_auto: ENV["SMTP_STARTTLS"] != "false",
      open_timeout:         10,
      read_timeout:         20
    }
    config.action_mailer.raise_delivery_errors = true
  else
    config.action_mailer.delivery_method = :test
    config.action_mailer.raise_delivery_errors = false
    Rails.logger.warn("[mailer] SMTP_HOST 미설정 — production에서도 :test로 동작 (deliveries 큐만 채움). ENV 설정 후 재배포 필요.") rescue nil
  end
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {
    host:     ENV.fetch("APP_HOST",     "ximtier.158.247.235.31.nip.io"),
    protocol: ENV.fetch("APP_PROTOCOL", "http")
  }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Host authorization — 정식 도메인 + nip.io 임시 도메인 + Vultr IP 직접 접속 모두 허용
  config.hosts = [
    "ximtier.com",
    "www.ximtier.com",
    "ximtier.158.247.235.31.nip.io",
    "158.247.235.31",
    /.*\.nip\.io/, # 향후 stage/preview 호스트도 nip.io로 운용 가능
    ENV["EXTRA_HOST"]
  ].compact

  # /up 헬스체크는 host 검사 면제 (kamal-proxy 헬스체크 우회)
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

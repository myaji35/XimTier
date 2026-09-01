class ApplicationController < ActionController::Base
  include Pagy::Backend
  helper Pagy::Frontend

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_locale

  helper_method :form_timestamp

  private

  # /admin 에서 온 관리자는 원래 목적지로, 직접 로그인한 관리자는 한국어 홈으로 보낸다.
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || home_path(locale: :ko)
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed = params[:locale]&.to_sym
    return parsed if I18n.available_locales.include?(parsed)

    nil
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def form_timestamp
    Rails.application.message_verifier(:marketing_form_submission).generate(Time.current.to_f)
  end

  def invalid_form_submission_time?
    return false if Rails.env.test?

    rendered_at = Rails.application.message_verifier(:marketing_form_submission).verified(params[:form_ts])
    return true unless rendered_at.is_a?(Numeric)

    elapsed = Time.current.to_f - rendered_at
    elapsed < 3.seconds || elapsed > 6.hours
  end

  def log_honeypot_submission(form:, email:, reason: "honeypot")
    Rails.logger.warn(
      "Honeypot submission dropped form=#{form} reason=#{reason} email=#{masked_email(email)} at=#{Time.current.iso8601}"
    )
  end

  def masked_email(email)
    return "(none)" if email.blank?

    local, domain = email.to_s.split("@", 2)
    masked = "#{local.first(2)}***"
    domain.present? ? "#{masked}@#{domain}" : masked
  end
end

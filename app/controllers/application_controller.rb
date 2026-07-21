class ApplicationController < ActionController::Base
  include Pagy::Backend
  helper Pagy::Frontend

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_locale

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
end

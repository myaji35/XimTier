class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_locale

  private

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

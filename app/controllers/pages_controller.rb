class PagesController < ApplicationController
  def home; end
  def deck; end

  def deck_detail
    @slug = params[:slug]
    @detail = helpers.deck_detail(@slug)
    redirect_to deck_path(locale: I18n.locale) and return unless @detail
  end
  def problem; end
  def solution; end
  def how_it_works; end
  def why_not_llm; end
  def use_cases; end

  def case_study
    slug = params[:slug].to_s.tr("-", "_")  # smart-city → smart_city
    @case_key = slug.to_sym
    @case = I18n.t("cases.#{slug}", default: nil)
    raise ActionController::RoutingError, "Not Found" if @case.nil?
  end
  def pricing; end
  def platform_api; end
  def team; end
  def vision; end
  def market; end
  def investors; end
  def privacy; end
  def terms; end
  def contact; end
  def demo; end

  def v3_overview; end
  def v3_data; end
  def v3_analysis; end
  def v3_solutions; end
  def v3_usage; end

  def v3_detail
    @slug = params[:slug].to_s
    @detail = I18n.t("v3detail.#{@slug.tr('-', '_')}", default: nil)
    redirect_to v3_overview_path(locale: I18n.locale) and return if @detail.nil?
  end
end

class PagesController < ApplicationController
  def home; end
  def problem; end
  def solution; end
  def how_it_works; end
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
end

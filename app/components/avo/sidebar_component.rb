# frozen_string_literal: true

# avo-3.32.1 에서 eject — 메뉴 그룹/순서 커스텀 (ISS-028). gem 업그레이드 시 원본과 diff 확인 필요

class Avo::SidebarComponent < Avo::BaseComponent
  MENU = {
    "리드 관리" => %w[demo_requests comments downloads contact_inquiries],
    "콘텐츠 관리" => %w[case_studies case_media case_comments],
    "회원 관리" => %w[users]
  }.freeze

  TOOL_ORDER = %w[kpi leads content_cases ops_wiki harness_dashboard].freeze

  prop :sidebar_open, default: false
  prop :for_mobile, default: false

  def dashboards
    return [] unless Avo.plugin_manager.installed?("avo-dashboards")

    Avo::Dashboards.dashboard_manager.dashboards_for_navigation
  end

  def resources
    Avo.resource_manager.resources_for_navigation helpers._current_user
  end

  def grouped_resources
    available_resources = resources
    grouped = MENU.filter_map do |group_name, route_keys|
      group_resources = route_keys.filter_map do |route_key|
        available_resources.find { |resource| resource.route_key == route_key }
      end

      [group_name, group_resources] if group_resources.present?
    end

    configured_route_keys = MENU.values.flatten
    other_resources = available_resources
      .reject { |resource| configured_route_keys.include?(resource.route_key) }
      .sort_by(&:navigation_label)

    grouped << ["기타", other_resources] if other_resources.present?
    grouped
  end

  def tools
    Avo.tool_manager.tools_for_navigation.sort_by do |partial|
      [TOOL_ORDER.index(partial) || TOOL_ORDER.length, partial]
    end
  end

  def stimulus_target
    @for_mobile ? "mobileSidebar" : "sidebar"
  end
end

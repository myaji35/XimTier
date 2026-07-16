# For more information regarding these settings check out our docs https://docs.avohq.io
# The values disaplayed here are the default ones. Uncomment and change them to fit your needs.
Avo.configure do |config|
  ## == Routing ==
  config.root_path = "/admin"
  # used only when you have custom `map` configuration in your config.ru
  # config.prefix_path = "/internal"

  # Where should the user be redirected when visiting the `/avo` url
  # 기본값은 Avo 데모 페이지("Welcome to Avo" + 제품 홍보 문구)다. 실제 업무 화면으로 보낸다.
  config.home_path = "/admin/kpi"

  ## == Licensing ==
  # config.license_key = ENV['AVO_LICENSE_KEY']

  ## == Set the context ==
  config.set_context do
    # Return a context object that gets evaluated within Avo::ApplicationController
  end

  ## == Authentication (PRD §FR-7) ==
  config.current_user_method = :current_user
  config.authenticate_with do
    redirect_to main_app.new_user_session_path unless current_user&.admin?
  end

  ## == Authorization ==
  # config.is_admin_method = :is_admin
  # config.is_developer_method = :is_developer
  # config.authorization_methods = {
  #   index: 'index?',
  #   show: 'show?',
  #   edit: 'edit?',
  #   new: 'new?',
  #   update: 'update?',
  #   create: 'create?',
  #   destroy: 'destroy?',
  #   search: 'search?',
  # }
  # Avo 인가(authorization)는 avo-pro 전용 기능이다. OSS 판에는 no-op 스텁만 들어 있어
  # authorization_client 를 :pundit 으로 바꿔도 정책이 호출되지 않는다
  # (configuration.rb: authorization_enabled? = installed?("avo-pro") && !client.nil?).
  # 따라서 방어는 모델 계층(User#readonly_admin_flag!, before_destroy)에서 한다. — ISS-007
  config.authorization_client = nil
  config.explicit_authorization = true

  ## == Localization ==
  # config.locale = 'en-US'

  ## == Resource options ==
  # config.resource_row_controls_config = {
  #   placement: :right,
  #   float: false,
  #   show_on_hover: false
  # }.freeze
  # config.model_resource_mapping = {}
  # config.default_view_type = :table
  # config.per_page = 24
  # config.per_page_steps = [12, 24, 48, 72]
  # config.via_per_page = 8
  # config.id_links_to_resource = false
  # config.pagination = -> do
  #   {
  #     type: :default,
  #     size: 9, # `[1, 2, 2, 1]` for pagy < 9.0
  #   }
  # end

  ## == Response messages dismiss time ==
  # config.alert_dismiss_time = 5000


  ## == Number of search results to display ==
  # config.search_results_count = 8

  ## == Associations lookup list limit ==
  # config.associations_lookup_list_limit = 1000

  ## == Cache options ==
  ## Provide a lambda to customize the cache store used by Avo.
  ## We compute the cache store by default, this is NOT the default, just an example.
  # config.cache_store = -> {
  #   ActiveSupport::Cache.lookup_store(:solid_cache_store)
  # }
  # config.cache_resources_on_index_view = true

  ## == Turbo options ==
  # config.turbo = -> do
  #   {
  #     instant_click: true
  #   }
  # end

  ## == Logger ==
  # config.logger = -> {
  #   file_logger = ActiveSupport::Logger.new(Rails.root.join("log", "avo.log"))
  #
  #   file_logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  #   file_logger.formatter = proc do |severity, time, progname, msg|
  #     "[Avo] #{time}: #{msg}\n".tap do |i|
  #       puts i
  #     end
  #   end
  #
  #   file_logger
  # }

  ## == Customization ==
  config.click_row_to_view_record = true
  config.app_name = "XimTier 관리자"
  # config.timezone = 'UTC'
  # config.currency = 'USD'
  # config.hide_layout_when_printing = false
  # config.full_width_container = false
  # config.full_width_index_view = false
  # config.search_debounce = 300
  # config.view_component_path = "app/components"
  # config.display_license_request_timeout_error = true
  # config.disabled_features = []
  # config.buttons_on_form_footers = true
  # config.field_wrapper_layout = true
  # config.resource_parent_controller = "Avo::ResourcesController"
  # config.first_sorting_option = :desc # :desc or :asc
  # config.exclude_from_status = []
  # config.model_generator_hook = true

  ## == Branding ==
  # config.branding = {
  #   colors: {
  #     background: "248 246 242",
  #     100 => "#CEE7F8",
  #     400 => "#399EE5",
  #     500 => "#0886DE",
  #     600 => "#066BB2",
  #   },
  #   chart_colors: ["#0B8AE2", "#34C683", "#2AB1EE", "#34C6A8"],
  #   logo: "/avo-assets/logo.png",
  #   logomark: "/avo-assets/logomark.png",
  #   placeholder: "/avo-assets/placeholder.svg",
  #   favicon: "/avo-assets/favicon.ico"
  # }

  ## == Breadcrumbs ==
  # config.display_breadcrumbs = true
  # config.set_initial_breadcrumbs do
  #   add_breadcrumb "Home", '/avo'
  # end

  ## == Menus ==
  # main_menu(메뉴 편집기)는 avo-pro 전용이다. OSS 판에서 설정하면 무시되고
  # "The menu editor is available exclusively with the Pro license" 경고만 뜬다
  # (avo.rb:191). 인가(authorization_client)와 같은 구조다 — ISS-007 참조.
  # 따라서 메뉴 순서는 제어할 수 없고, 리소스명 한글화(config/locales/avo.ko.yml)로만
  # 가독성을 확보한다.
  # config.main_menu = -> { ... }
  # config.profile_menu = -> {
  #   link "Profile", path: "/avo/profile", icon: "heroicons/outline/user-circle"
  # }
end

Rails.application.routes.draw do
  mount_avo
  devise_for :users
  # Health check (Kamal proxy / load balancers)
  get "up" => "rails/health#show", as: :rails_health_check

  # Root: Accept-Language 기반 자동 리디렉트
  root to: redirect { |_params, request|
    lang = request.env["HTTP_ACCEPT_LANGUAGE"].to_s
    locale = lang.start_with?("ko") ? "ko" : (lang.empty? ? "ko" : "en")
    "/#{locale}"
  }

  # --- 다국어 라우팅 (/ko, /en) ---
  scope "(:locale)", locale: /ko|en/ do
    get "/", to: "pages#home", as: :home

    # Marketing pages
    get "/problem",      to: "pages#problem"
    get "/solution",     to: "pages#solution"
    get "/how-it-works", to: "pages#how_it_works", as: :how_it_works
    get "/use-cases",    to: "pages#use_cases",    as: :use_cases
    get "/pricing",      to: "pages#pricing"
    get "/platform-api", to: "pages#platform_api", as: :platform_api

    # Company
    get "/company/team",      to: "pages#team",      as: :team
    get "/company/vision",    to: "pages#vision",    as: :vision
    get "/company/investors", to: "pages#investors", as: :investors

    # Legal
    get "/privacy", to: "pages#privacy"
    get "/terms",   to: "pages#terms"

    # Conversion (stubs — M3에서 구현)
    get "/contact", to: "pages#contact"
    get "/demo",    to: "pages#demo"
  end
end

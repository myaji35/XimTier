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
    get "/cases/:slug",  to: "pages#case_study",   as: :case_study, constraints: { slug: /manufacturing|hospital|public|smart-city/ }
    get "/pricing",      to: "pages#pricing"
    get "/platform-api", to: "pages#platform_api", as: :platform_api

    # Company
    get "/company/team",      to: "pages#team",      as: :team
    get "/company/vision",    to: "pages#vision",    as: :vision
    get "/company/market",    to: "pages#market",    as: :market
    get  "/company/investors", to: "downloads#new",    as: :investors
    post "/company/investors", to: "downloads#create"
    get  "/ir/:token",         to: "downloads#show",   as: :ir_download

    # Legal
    get "/privacy", to: "pages#privacy"
    get "/terms",   to: "pages#terms"

    # Contact + Demo
    get  "/contact", to: "contact_inquiries#new",    as: :contact
    post "/contact", to: "contact_inquiries#create"

    get  "/demo", to: "demo_requests#new",    as: :demo
    post "/demo", to: "demo_requests#create"

    # 사용자 대시보드 (Devise 로그인 필요)
    get "/dashboard", to: "dashboards#show", as: :dashboard
    resources :demo_requests, only: [], path: "demo-requests" do
      resources :comments, only: [:create]
    end
  end

  # letter_opener_web for development
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end

if defined? ::Avo
  Avo::Engine.routes.draw do
    # This route is not protected, secure it with authentication if needed.
    get "code_wiki", to: "tools#code_wiki", as: :code_wiki
  end
end

if defined? ::Avo
  Avo::Engine.routes.draw do
    # This route is not protected, secure it with authentication if needed.
    get "harness_dashboard", to: "tools#harness_dashboard", as: :harness_dashboard
  end
end

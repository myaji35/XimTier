require "rails_helper"

# PRD §FR-7 — Avo /admin must be gated by Devise + User#admin
RSpec.describe "Avo admin auth", type: :request do
  it "redirects anonymous visitors to the Devise sign-in page" do
    get "/admin"
    expect(response).to redirect_to("/users/sign_in")
  end

  it "redirects non-admin users to the Devise sign-in page" do
    user = create(:user, admin: false)
    sign_in user
    get "/admin"
    expect(response).to redirect_to("/users/sign_in")
  end

  it "lets admin users through to Avo" do
    admin = create(:user, :admin)
    sign_in admin
    get "/admin"
    expect(response.status).to be_in([200, 302])
    # Avo's root may 302 to a dashboard; either way we should NOT be sent back to login.
    expect(response.location.to_s).not_to include("/users/sign_in") if response.redirect?
  end

  it "exposes the leads tool to admin users" do
    admin = create(:user, :admin)
    sign_in admin
    get "/admin/leads"
    expect(response).to have_http_status(:ok)
  end

  it "streams leads.csv with the right content-type for admins" do
    admin = create(:user, :admin)
    sign_in admin
    get "/admin/leads.csv"
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("text/csv")
    expect(response.body.lines.first.strip).to start_with("kind,id,name,email")
  end

  it "exposes the KPI dashboard to admin users" do
    admin = create(:user, :admin)
    sign_in admin
    get "/admin/kpi"
    expect(response).to have_http_status(:ok)
  end
end

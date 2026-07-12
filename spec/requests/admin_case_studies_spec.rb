require "rails_helper"

RSpec.describe "Admin CaseStudy resource", type: :request do
  it "lets an admin list case studies" do
    admin = create(:user, :admin)
    sign_in admin
    get "/admin/resources/case_studies"
    expect(response).to have_http_status(:ok)
  end

  it "redirects a non-admin away from case studies" do
    sign_in create(:user, admin: false)
    get "/admin/resources/case_studies"
    expect(response).to redirect_to("/users/sign_in")
  end
end

require "rails_helper"

RSpec.describe "Admin CaseComment resource", type: :request do
  it "lets an admin list case comments" do
    sign_in create(:user, :admin)
    get "/admin/resources/case_comments"
    expect(response).to have_http_status(:ok)
  end
end

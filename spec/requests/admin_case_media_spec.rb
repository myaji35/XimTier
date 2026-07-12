require "rails_helper"

RSpec.describe "Admin CaseMedium resource", type: :request do
  it "lets an admin list case media" do
    sign_in create(:user, :admin)
    get "/admin/resources/case_media"
    expect(response).to have_http_status(:ok)
  end
end

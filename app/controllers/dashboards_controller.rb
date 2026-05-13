class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @demo_requests = current_user.demo_requests.recent.includes(:comments)
  end
end

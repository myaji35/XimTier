class Avo::ToolsController < Avo::ApplicationController
  def harness_dashboard
    @page_title = "Harness Dashboard"
    add_breadcrumb "Harness Dashboard"
    @harness = HarnessDashboardInspector.snapshot
  end
end

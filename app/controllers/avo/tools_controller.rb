class Avo::ToolsController < Avo::ApplicationController
  def harness_dashboard
    @page_title = "Harness Dashboard"
    add_breadcrumb "Harness Dashboard"
    @harness = HarnessDashboardInspector.snapshot
  end

  def code_wiki
    @page_title = "Code Wiki"
    add_breadcrumb "Code Wiki"
    @snapshot = CodeWikiInspector.snapshot
  end
end

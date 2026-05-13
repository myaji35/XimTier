class Avo::ToolsController < Avo::ApplicationController
  def code_wiki
    @page_title = "Code Wiki"
    add_breadcrumb "Code Wiki"
    @snapshot = CodeWikiInspector.snapshot
  end
end

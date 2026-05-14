class Avo::ToolsController < Avo::ApplicationController
  def harness_dashboard
    @page_title = "Harness Dashboard"
    add_breadcrumb "Harness Dashboard"
    @harness = HarnessDashboardInspector.snapshot
  end

  # PRD §FR-8 — 데모 신청 + 문의 통합 리스트 + 필터 + CSV 익스포트
  def leads
    @aggregator = LeadsAggregator.new(params.to_unsafe_h)

    respond_to do |format|
      format.html do
        @page_title = "Leads"
        add_breadcrumb "Leads"
        @leads   = @aggregator.leads
        @counts  = @aggregator.counts
        @filters = @aggregator.filters
      end
      format.csv do
        filename = "ximtier-leads-#{Time.current.strftime('%Y%m%d-%H%M%S')}.csv"
        send_data @aggregator.to_csv,
                  type: "text/csv; charset=utf-8",
                  disposition: %(attachment; filename="#{filename}")
      end
    end
  end

  # PRD §FR-9 — 일/주/월별 데모/문의/IR + 산업·언어 분포 KPI 대시보드
  def kpi
    @page_title = "KPI Dashboard"
    add_breadcrumb "KPI Dashboard"
    @kpi = AdminKpiSnapshot.build
  end
end

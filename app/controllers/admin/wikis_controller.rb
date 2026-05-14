class Admin::WikisController < ApplicationController
  layout "wiki"

  http_basic_authenticate_with(
    name: "admin",
    password: ENV.fetch("ADMIN_WIKI_PASSWORD", "gmldnjs!00")
  )

  helper_method :parse_month_view

  REPORTS_DIR = Rails.root.join("config", "reports_data").freeze

  def show
    @snapshot = CodeWikiInspector.snapshot
    @reports  = load_reports
    @roadmap  = load_roadmap
  end

  def report_show
    @snapshot = CodeWikiInspector.snapshot
    @reports  = load_reports
    @report   = @reports.find { |r| r["slug"] == params[:slug] }
    return redirect_to(admin_wiki_path, alert: "보고서를 찾을 수 없습니다.") unless @report

    html_path = REPORTS_DIR.join("#{@report['slug']}.html")
    return redirect_to(admin_wiki_path, alert: "HTML 파일이 없습니다.") unless File.exist?(html_path)

    @report_html = File.read(html_path)
  end

  def report_pdf
    pdf_path = REPORTS_DIR.join("#{params[:slug]}.pdf")
    return redirect_to(admin_wiki_path, alert: "PDF 파일이 없습니다.") unless File.exist?(pdf_path)

    send_file pdf_path,
              type: "application/pdf",
              disposition: params[:download].present? ? "attachment" : "inline",
              filename: "#{params[:slug]}.pdf"
  end

  private

  def load_roadmap
    cfg_path = Rails.root.join("config", "roadmap.yml")
    return nil unless File.exist?(cfg_path)
    yml = YAML.safe_load_file(cfg_path, permitted_classes: [Date, Time], aliases: true)
    return nil unless yml.is_a?(Hash)

    range_start = parse_month(yml.dig("range", "start"))
    range_end   = parse_month(yml.dig("range", "end"))
    return nil unless range_start && range_end

    months = []
    cur = range_start
    while cur <= range_end
      months << cur
      cur = cur.next_month
    end

    {
      "range_start" => range_start,
      "range_end"   => range_end,
      "months"      => months,
      "tracks"      => yml["tracks"] || []
    }
  end

  def parse_month(str)
    return nil unless str.is_a?(String)
    Date.parse("#{str}-01")
  rescue ArgumentError
    nil
  end
  public :parse_month
  alias_method :parse_month_view, :parse_month

  def load_reports
    cfg_path = Rails.root.join("config", "reports.yml")
    return [] unless File.exist?(cfg_path)

    yml = YAML.safe_load_file(cfg_path, permitted_classes: [Date, Time], aliases: true)
    list = (yml["reports"] || []).map { |r| r.merge(autofields(r)) }
    list.sort_by { |r| r["created_at"].to_s }.reverse
  end

  def autofields(report)
    slug = report["slug"]
    html = REPORTS_DIR.join("#{slug}.html")
    pdf  = REPORTS_DIR.join("#{slug}.pdf")
    {
      "has_html" => File.exist?(html),
      "has_pdf"  => File.exist?(pdf),
      "html_size_kb" => File.exist?(html) ? (File.size(html) / 1024.0).round : 0,
      "pdf_size_kb"  => File.exist?(pdf)  ? (File.size(pdf)  / 1024.0).round : 0,
      "updated_at"   => (File.exist?(pdf) ? File.mtime(pdf) : (File.exist?(html) ? File.mtime(html) : nil))
    }
  end
end

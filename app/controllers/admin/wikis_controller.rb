class Admin::WikisController < ApplicationController
  layout "wiki"

  # Basic Auth 가 1차 게이트이므로 update_roadmap JSON POST에만 CSRF skip.
  skip_before_action :verify_authenticity_token, only: [:update_roadmap]

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

  # POST /admin/wiki/roadmap (JSON)
  # Body: { range: {start, end}, tracks: [...] }
  def update_roadmap
    payload = JSON.parse(request.body.read) rescue nil
    return render(json: { ok: false, error: "잘못된 JSON" }, status: :bad_request) unless payload.is_a?(Hash)

    errors = validate_roadmap_payload(payload)
    return render(json: { ok: false, errors: errors }, status: :unprocessable_entity) if errors.any?

    cfg_path = Rails.root.join("config", "roadmap.yml")
    if File.exist?(cfg_path)
      backup = cfg_path.to_s + ".bak.#{Time.now.to_i}"
      FileUtils.cp(cfg_path, backup)
    end

    yaml_data = {
      "range" => {
        "start" => payload.dig("range", "start"),
        "end"   => payload.dig("range", "end")
      },
      "tracks" => Array(payload["tracks"]).map do |t|
        {
          "id" => t["id"],
          "title" => t["title"],
          "color" => t["color"],
          "phases" => Array(t["phases"]).map do |p|
            {
              "id" => p["id"],
              "title" => p["title"],
              "start" => p["start"],
              "end" => p["end"],
              "status" => p["status"] || "planned",
              "owner" => p["owner"].to_s,
              "reports" => Array(p["reports"]).reject(&:blank?),
              "milestone" => p["milestone"].to_s
            }
          end
        }
      end
    }

    File.write(cfg_path, yaml_data.to_yaml(line_width: -1))
    render json: { ok: true, saved_at: Time.current.iso8601 }
  end

  private

  VALID_STATUSES = %w[planned in_progress done blocked].freeze
  MONTH_RX = /\A\d{4}-(0[1-9]|1[0-2])\z/.freeze

  def validate_roadmap_payload(payload)
    errors = []
    rs = payload.dig("range", "start").to_s
    re = payload.dig("range", "end").to_s
    errors << "range.start 형식 오류" unless rs.match?(MONTH_RX)
    errors << "range.end 형식 오류"   unless re.match?(MONTH_RX)
    errors << "range.start ≤ range.end 이어야 함" if rs.match?(MONTH_RX) && re.match?(MONTH_RX) && rs > re

    tracks = payload["tracks"]
    errors << "tracks 배열 누락" unless tracks.is_a?(Array)
    return errors unless tracks.is_a?(Array)

    track_ids = []
    tracks.each_with_index do |t, ti|
      errors << "트랙 #{ti+1}: id 누락" if t["id"].to_s.empty?
      errors << "트랙 #{ti+1}: title 누락" if t["title"].to_s.empty?
      track_ids << t["id"]
      Array(t["phases"]).each_with_index do |p, pi|
        prefix = "트랙 \"#{t['title']}\" phase #{pi+1}"
        errors << "#{prefix}: id 누락" if p["id"].to_s.empty?
        errors << "#{prefix}: title 누락" if p["title"].to_s.empty?
        errors << "#{prefix}: start 형식 오류 (#{p['start']})" unless p["start"].to_s.match?(MONTH_RX)
        errors << "#{prefix}: end 형식 오류 (#{p['end']})"     unless p["end"].to_s.match?(MONTH_RX)
        if p["start"].to_s.match?(MONTH_RX) && p["end"].to_s.match?(MONTH_RX) && p["start"].to_s > p["end"].to_s
          errors << "#{prefix}: start ≤ end 이어야 함"
        end
        errors << "#{prefix}: status 잘못됨 (#{p['status']})" if p["status"].present? && !VALID_STATUSES.include?(p["status"])
      end
      dup = Array(t["phases"]).map { |p| p["id"] }.tally.select { |_, c| c > 1 }.keys
      errors << "트랙 \"#{t['title']}\": 중복 phase id #{dup.join(', ')}" if dup.any?
    end
    dup_tracks = track_ids.tally.select { |_, c| c > 1 }.keys
    errors << "중복 트랙 id: #{dup_tracks.join(', ')}" if dup_tracks.any?

    errors
  end

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

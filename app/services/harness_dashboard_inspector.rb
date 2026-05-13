# Harness 이슈 + 운영 KPI 라이브 수집
# /admin/harness_dashboard Avo Tool에서 사용
class HarnessDashboardInspector
  REGISTRY_PATH = Rails.root.join(".claude/issue-db/registry.json").freeze

  def self.snapshot
    data = load_registry
    issues = data["issues"] || []

    {
      available:        data.present?,
      mission:          data["mission"],
      strategy:         data["strategy"],
      by_status:        group_by_status(issues),
      by_priority:      issues.group_by { |i| i["priority"] }.transform_values(&:size),
      by_agent:         issues.group_by { |i| i["agent"] }.transform_values(&:size),
      ready_issues:     ready_issues(issues),
      in_progress:      issues.select { |i| i["status"] == "IN_PROGRESS" },
      completed_recent: completed_recent(issues),
      success_patterns: data.dig("knowledge", "success_patterns") || [],
      meta_observations: data.dig("knowledge", "meta_observations") || [],
      stats: {
        total:     issues.size,
        completed: issues.count { |i| i["status"] == "COMPLETED" },
        ready:     issues.count { |i| i["status"] == "READY" },
        in_prog:   issues.count { |i| i["status"] == "IN_PROGRESS" },
        blocked:   issues.count { |i| i["status"] == "BLOCKED" }
      },
      opus_budget: data["opus_budget_state"] || {},
      lead_kpis:   lead_kpis,
      generated_at: Time.current
    }
  end

  def self.load_registry
    return {} unless File.exist?(REGISTRY_PATH)
    JSON.parse(File.read(REGISTRY_PATH))
  rescue JSON::ParserError, Errno::ENOENT
    {}
  end

  def self.group_by_status(issues)
    statuses = %w[READY IN_PROGRESS COMPLETED BLOCKED FAILED]
    statuses.each_with_object({}) { |s, h| h[s] = 0 }.tap do |hash|
      issues.each { |i| hash[i["status"]] = (hash[i["status"]] || 0) + 1 }
    end
  end

  def self.ready_issues(issues)
    issues.select { |i| i["status"] == "READY" }
          .sort_by { |i| priority_weight(i["priority"]) }
          .first(5)
  end

  def self.completed_recent(issues)
    issues.select { |i| i["status"] == "COMPLETED" && i["completed_at"] }
          .sort_by { |i| i["completed_at"].to_s }
          .reverse.first(5)
  end

  def self.priority_weight(priority)
    { "P0" => 0, "P1" => 1, "P2" => 2, "P3" => 3 }[priority] || 9
  end

  def self.lead_kpis
    return {} unless defined?(DemoRequest) && defined?(ContactInquiry) && defined?(Download)
    today = Time.current.beginning_of_day
    week  = 7.days.ago
    month = 30.days.ago
    {
      demo_today:    DemoRequest.where("created_at >= ?", today).count,
      demo_week:     DemoRequest.where("created_at >= ?", week).count,
      demo_month:    DemoRequest.where("created_at >= ?", month).count,
      demo_total:    DemoRequest.count,
      contact_today: ContactInquiry.where("created_at >= ?", today).count,
      contact_week:  ContactInquiry.where("created_at >= ?", week).count,
      contact_total: ContactInquiry.count,
      ir_today:      Download.where("created_at >= ?", today).count,
      ir_week:       Download.where("created_at >= ?", week).count,
      ir_total:      Download.count,
      ir_clicks:     Download.sum(:downloaded_count),
      users_total:   User.count,
      industry_dist: DemoRequest.joins(:user).group("users.industry").count
    }
  rescue StandardError => e
    { error: e.message }
  end
end

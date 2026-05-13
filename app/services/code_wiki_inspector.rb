# 런타임 코드 구조 + Harness 상태 + RSpec 상태 수집기
# /admin/wiki (Basic auth) 에서 사용
class CodeWikiInspector
  ROOT = Rails.root

  def self.snapshot
    {
      components:     view_components,
      stimulus:       stimulus_controllers,
      controllers:    rails_controllers,
      models:         models,
      pages:          page_views,
      locales:        locales,
      agents:         harness_agents,
      issues:         harness_issues,
      stats:          stats,
      generated_at:   Time.current
    }
  end

  def self.view_components
    Dir.glob(ROOT.join("app/components/*_component.rb")).sort.map do |f|
      name = File.basename(f, ".rb").camelize
      template = f.sub(/\.rb\z/, ".html.erb")
      {
        name: name,
        file: f.sub(ROOT.to_s + "/", ""),
        has_template: File.exist?(template),
        lines: file_lines(f)
      }
    end
  end

  def self.stimulus_controllers
    Dir.glob(ROOT.join("app/javascript/controllers/*_controller.js")).sort.map do |f|
      base = File.basename(f, ".js").sub(/_controller\z/, "")
      {
        name: base,
        identifier: base.tr("_", "-"),
        file: f.sub(ROOT.to_s + "/", ""),
        lines: file_lines(f)
      }
    end
  end

  def self.rails_controllers
    Dir.glob(ROOT.join("app/controllers/**/*_controller.rb")).sort.map do |f|
      next if f.include?("/avo/")
      base = File.basename(f, ".rb")
      {
        name: base.camelize,
        file: f.sub(ROOT.to_s + "/", ""),
        lines: file_lines(f)
      }
    end.compact
  end

  def self.models
    Dir.glob(ROOT.join("app/models/*.rb")).sort.map do |f|
      base = File.basename(f, ".rb")
      next if %w[application_record].include?(base)
      {
        name: base.camelize,
        file: f.sub(ROOT.to_s + "/", ""),
        lines: file_lines(f)
      }
    end.compact
  end

  def self.page_views
    Dir.glob(ROOT.join("app/views/pages/*.html.erb")).sort.map do |f|
      base = File.basename(f, ".html.erb")
      {
        name: base.tr("_", " ").titleize,
        slug: base,
        file: f.sub(ROOT.to_s + "/", ""),
        lines: file_lines(f)
      }
    end
  end

  def self.locales
    %w[ko en].map do |loc|
      files = Dir.glob(ROOT.join("config/locales/#{loc}/*.yml"))
      key_count = files.sum { |f| YAML.load_file(f).to_s.scan(/\w+:/).size rescue 0 }
      {
        locale: loc,
        file_count: files.size,
        files: files.map { |f| File.basename(f) }.sort,
        approx_keys: key_count
      }
    end
  end

  def self.harness_agents
    agents_dir = ROOT.join(".claude/agents")
    return [] unless File.directory?(agents_dir)
    Dir.glob("#{agents_dir}/*.md").sort.map do |f|
      name = File.basename(f, ".md")
      {
        name: name,
        file: f.sub(ROOT.to_s + "/", ""),
        size_kb: (File.size(f) / 1024.0).round(1)
      }
    end
  rescue StandardError
    []
  end

  def self.harness_issues
    registry = ROOT.join(".claude/issue-db/registry.json")
    return { available: false } unless File.exist?(registry)
    data = JSON.parse(File.read(registry))
    issues = data["issues"] || []
    by_status = issues.group_by { |i| i["status"] }.transform_values(&:size)
    {
      available:       true,
      total:           issues.size,
      by_status:       by_status,
      by_priority:     issues.group_by { |i| i["priority"] }.transform_values(&:size),
      latest:          issues.last(5).map { |i| { id: i["id"], title: i["title"], status: i["status"], priority: i["priority"] } },
      success_patterns: (data.dig("knowledge", "success_patterns") || []).size
    }
  rescue StandardError => e
    { available: false, error: e.message }
  end

  def self.stats
    {
      ruby:      "#{RUBY_VERSION} (#{RUBY_PLATFORM})",
      rails:     Rails.version,
      env:       Rails.env,
      git_sha:   (`git rev-parse --short HEAD 2>/dev/null`.strip rescue nil),
      git_branch:(`git rev-parse --abbrev-ref HEAD 2>/dev/null`.strip rescue nil),
      total_files: file_count
    }
  end

  def self.file_lines(path)
    File.foreach(path).count
  rescue StandardError
    0
  end

  def self.file_count
    Dir.glob(ROOT.join("app/**/*")).count { |f| File.file?(f) }
  rescue StandardError
    0
  end
end

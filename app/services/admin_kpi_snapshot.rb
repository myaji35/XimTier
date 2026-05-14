# Admin KPI snapshot for /admin/kpi (Avo tool) — PRD §FR-9
#   - daily/weekly/monthly counts of demo + contact + IR download
#   - industry distribution + locale (ko/en) split
#   - last 14-day trend buckets for chart rendering
class AdminKpiSnapshot
  def self.build
    today_start = Time.current.beginning_of_day
    week_start  = 7.days.ago
    month_start = 30.days.ago

    {
      generated_at: Time.current,
      windows: {
        today: today_start,
        week:  week_start,
        month: month_start
      },
      counts: {
        demo: {
          today: DemoRequest.where("created_at >= ?", today_start).count,
          week:  DemoRequest.where("created_at >= ?", week_start).count,
          month: DemoRequest.where("created_at >= ?", month_start).count,
          total: DemoRequest.count
        },
        contact: {
          today: ContactInquiry.where("created_at >= ?", today_start).count,
          week:  ContactInquiry.where("created_at >= ?", week_start).count,
          month: ContactInquiry.where("created_at >= ?", month_start).count,
          total: ContactInquiry.count
        },
        ir_download: {
          today: Download.where("created_at >= ?", today_start).count,
          week:  Download.where("created_at >= ?", week_start).count,
          month: Download.where("created_at >= ?", month_start).count,
          total: Download.count,
          clicks_total: Download.sum(:downloaded_count)
        }
      },
      industry: {
        demo:    DemoRequest.joins(:user).group("users.industry").count.transform_keys { |k| industry_label(k) },
        contact: ContactInquiry.group(:industry).count.transform_keys { |k| industry_label(k) }
      },
      locale: {
        demo:    DemoRequest.group(:locale).count,
        contact: ContactInquiry.group(:locale).count,
        ir:      Download.group(:locale).count
      },
      status: {
        demo:    DemoRequest.group(:status).count,
        contact: { "handled" => ContactInquiry.where(handled: true).count,
                   "unhandled" => ContactInquiry.where(handled: false).count }
      },
      asset_split: Download.group(:asset).count.transform_keys { |k| asset_label(k) },
      trend_14d: trend_14d,
      conversion: conversion_metrics
    }
  end

  def self.trend_14d
    days = (13.days.ago.to_date..Date.current).to_a
    bucketed = {
      demo:    bucket(DemoRequest,    days),
      contact: bucket(ContactInquiry, days),
      ir:      bucket(Download,       days)
    }
    {
      days:    days.map { |d| d.strftime("%m/%d") },
      demo:    days.map { |d| bucketed[:demo][d]    || 0 },
      contact: days.map { |d| bucketed[:contact][d] || 0 },
      ir:      days.map { |d| bucketed[:ir][d]      || 0 }
    }
  end

  def self.bucket(klass, days)
    klass.where(created_at: days.first.beginning_of_day..days.last.end_of_day)
         .group("DATE(created_at)")
         .count
         .transform_keys { |k| k.is_a?(String) ? Date.parse(k) : k.to_date }
  end

  def self.conversion_metrics
    total_demo    = DemoRequest.count
    scheduled     = DemoRequest.where(status: %i[scheduled completed]).count
    ir_total      = Download.count
    {
      demo_to_scheduled_pct: total_demo.zero? ? 0 : ((scheduled.to_f / total_demo) * 100).round(1),
      ir_total:              ir_total,
      ir_target_y1:          100,
      ir_target_pct:         ((ir_total.to_f / 100) * 100).round(1)
    }
  end

  def self.industry_label(key)
    enum_label(key, User.industries)
  end

  def self.asset_label(key)
    enum_label(key, Download.assets)
  end

  # Normalize an enum bucket key (could be the string label, the integer code,
  # or a symbol) into its human-readable label.
  def self.enum_label(key, enum_map)
    return "unknown" if key.nil?

    string_key = key.to_s
    return string_key if enum_map.key?(string_key)

    inverted = enum_map.invert
    inverted[key] || inverted[Integer(string_key, exception: false)] || string_key
  end
end

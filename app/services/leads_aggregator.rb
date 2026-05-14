# Unified view of demo requests + contact inquiries.
# Used by /admin/leads (Avo tool) with filters (kind/status/industry/locale/range/search) and CSV export.
class LeadsAggregator
  Lead = Struct.new(
    :kind, :id, :name, :email, :company, :role, :industry, :status,
    :message, :source, :locale, :created_at, :record_path,
    keyword_init: true
  )

  KINDS    = %w[demo contact].freeze
  STATUSES = %w[pending scheduled completed cancelled handled unhandled].freeze
  RANGES   = %w[today week month all].freeze

  def initialize(params = {})
    @params = (params || {}).stringify_keys
  end

  def filters
    {
      kind:     @params["kind"].presence,
      status:   @params["status"].presence,
      industry: @params["industry"].presence,
      locale:   @params["locale"].presence,
      range:    (@params["range"].presence || "all"),
      q:        @params["q"].presence
    }
  end

  CONTACT_ONLY_STATUSES = %w[handled unhandled].freeze
  DEMO_ONLY_STATUSES    = %w[pending scheduled completed cancelled].freeze

  def leads
    rows = []
    rows.concat(demo_leads)    if include_demos?
    rows.concat(contact_leads) if include_contacts?
    rows.sort_by(&:created_at).reverse
  end

  def include_demos?
    return false if filters[:kind] == "contact"
    return false if filters[:status] && CONTACT_ONLY_STATUSES.include?(filters[:status])
    true
  end

  def include_contacts?
    return false if filters[:kind] == "demo"
    return false if filters[:status] && DEMO_ONLY_STATUSES.include?(filters[:status])
    true
  end

  def counts
    {
      total:    leads.size,
      demo:     leads.count { |l| l.kind == "demo" },
      contact:  leads.count { |l| l.kind == "contact" }
    }
  end

  def to_csv
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << %w[kind id name email company role industry status source locale created_at message]
      leads.each do |l|
        csv << [
          l.kind, l.id, l.name, l.email, l.company, l.role,
          l.industry, l.status, l.source, l.locale,
          l.created_at&.iso8601, l.message.to_s.tr("\n", " ").truncate(500)
        ]
      end
    end
  end

  private

  def demo_leads
    scope = DemoRequest.includes(:user).recent
    scope = scope.where(status: filters[:status]) if filters[:status] && DemoRequest.statuses.key?(filters[:status])
    scope = scope.where(locale: filters[:locale]) if filters[:locale]
    scope = scope.where(users: { industry: User.industries[filters[:industry]] }).joins(:user) if filters[:industry] && User.industries.key?(filters[:industry])
    scope = filter_range(scope)
    if filters[:q]
      q = "%#{filters[:q]}%"
      scope = scope.joins(:user).where("users.email LIKE :q OR users.name LIKE :q OR users.company LIKE :q OR demo_requests.data_description LIKE :q", q: q)
    end

    scope.map do |d|
      Lead.new(
        kind: "demo",
        id:   d.id,
        name: d.user&.name,
        email: d.user&.email,
        company: d.user&.company,
        role: d.user&.role,
        industry: d.user&.industry,
        status: d.status,
        message: d.data_description,
        source: d.source,
        locale: d.locale,
        created_at: d.created_at,
        record_path: "/admin/resources/demo_requests/#{d.id}"
      )
    end
  end

  def contact_leads
    return [] if filters[:status] && DEMO_ONLY_STATUSES.include?(filters[:status])

    scope = ContactInquiry.recent
    scope = case filters[:status]
            when "handled"   then scope.where(handled: true)
            when "unhandled" then scope.where(handled: false)
            else scope
            end
    scope = scope.where(locale: filters[:locale]) if filters[:locale]
    scope = scope.where(industry: ContactInquiry.industries[filters[:industry]]) if filters[:industry] && ContactInquiry.industries.key?(filters[:industry])
    scope = filter_range(scope)
    if filters[:q]
      q = "%#{filters[:q]}%"
      scope = scope.where("name LIKE :q OR email LIKE :q OR company LIKE :q OR message LIKE :q", q: q)
    end

    scope.map do |c|
      Lead.new(
        kind: "contact",
        id:   c.id,
        name: c.name,
        email: c.email,
        company: c.company,
        role: nil,
        industry: c.industry,
        status: c.handled ? "handled" : "unhandled",
        message: c.message,
        source: c.source,
        locale: c.locale,
        created_at: c.created_at,
        record_path: "/admin/resources/contact_inquiries/#{c.id}"
      )
    end
  end

  def filter_range(scope)
    case filters[:range]
    when "today" then scope.where("created_at >= ?", Time.current.beginning_of_day)
    when "week"  then scope.where("created_at >= ?", 7.days.ago)
    when "month" then scope.where("created_at >= ?", 30.days.ago)
    else scope
    end
  end
end

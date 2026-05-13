class Avo::Resources::DemoRequest < Avo::BaseResource
  self.includes = [:user, { data_file_attachment: :blob }, :comments]
  self.search = {
    query: -> {
      query.joins(:user)
           .where("users.email LIKE :q OR users.name LIKE :q OR users.company LIKE :q OR demo_requests.data_description LIKE :q", q: "%#{params[:q]}%")
    }
  }

  def fields
    field :id,           as: :id
    field :user,         as: :belongs_to
    field :status,       as: :select, options: DemoRequest.statuses.keys.index_by(&:itself), display_with_value: true
    field :data_description, as: :textarea, hide_on: :index
    field :data_file,    as: :file, hide_on: :index
    field :preferred_at, as: :date_time
    field :scheduled_at, as: :date_time
    field :meeting_url,  as: :text, hide_on: :index
    field :admin_notes,  as: :textarea, hide_on: :index
    field :locale,       as: :select, options: { ko: "ko", en: "en" }
    field :source,       as: :text, hide_on: :index
    field :comments_count, as: :number,
          format_using: -> { record.comments.count.to_s }, only_on: :index
    field :created_at,   as: :date_time, sortable: true, only_on: :index
  end
end

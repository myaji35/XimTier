class Avo::Resources::DemoRequest < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :data_description, as: :textarea
    field :preferred_at, as: :date_time
    field :status, as: :number
    field :scheduled_at, as: :date_time
    field :meeting_url, as: :text
    field :admin_notes, as: :textarea
    field :locale, as: :text
    field :source, as: :text
  end
end

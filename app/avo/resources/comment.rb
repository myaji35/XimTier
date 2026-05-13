class Avo::Resources::Comment < Avo::BaseResource
  self.includes = [:user, :demo_request]

  def fields
    field :id,           as: :id
    field :demo_request, as: :belongs_to
    field :user,         as: :belongs_to
    field :by_admin,     as: :boolean
    field :body,         as: :textarea
    field :created_at,   as: :date_time, sortable: true, only_on: :index
  end
end

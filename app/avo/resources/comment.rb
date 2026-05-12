class Avo::Resources::Comment < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :demo_request, as: :belongs_to
    field :body, as: :textarea
    field :by_admin, as: :boolean
  end
end

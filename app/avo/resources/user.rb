class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :name, as: :text
    field :company, as: :text
    field :role, as: :text
    field :industry, as: :select, enum: ::User.industries
    field :admin, as: :boolean
    field :locale, as: :text
  end
end

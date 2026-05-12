class Avo::Resources::ContactInquiry < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :email, as: :text
    field :company, as: :text
    field :industry, as: :number
    field :message, as: :textarea
    field :source, as: :text
    field :locale, as: :text
    field :handled, as: :boolean
  end
end

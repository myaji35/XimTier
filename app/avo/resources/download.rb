class Avo::Resources::Download < Avo::BaseResource
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
    field :asset, as: :number
    field :download_token, as: :text
    field :downloaded_count, as: :number
    field :locale, as: :text
  end
end

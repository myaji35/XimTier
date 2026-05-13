class Avo::Resources::ContactInquiry < Avo::BaseResource
  self.search = {
    query: -> {
      query.where("name LIKE :q OR email LIKE :q OR company LIKE :q OR message LIKE :q", q: "%#{params[:q]}%")
    }
  }

  def fields
    field :id,       as: :id
    field :name,     as: :text
    field :email,    as: :text
    field :company,  as: :text
    field :industry, as: :select, options: ContactInquiry.industries.keys.index_by(&:itself)
    field :message,  as: :textarea, hide_on: :index
    field :locale,   as: :text
    field :handled,  as: :boolean
    field :source,   as: :text, hide_on: :index
    field :created_at, as: :date_time, sortable: true, only_on: :index
  end
end

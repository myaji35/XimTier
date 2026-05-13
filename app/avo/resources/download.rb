class Avo::Resources::Download < Avo::BaseResource
  self.search = {
    query: -> {
      query.where("email LIKE :q OR name LIKE :q OR company LIKE :q", q: "%#{params[:q]}%")
    }
  }

  def fields
    field :id,       as: :id
    field :email,    as: :text
    field :name,     as: :text
    field :company,  as: :text
    field :role,     as: :text
    field :asset,    as: :select, options: Download.assets.keys.index_by(&:itself)
    field :downloaded_count, as: :number
    field :download_token, as: :text, hide_on: :index, readonly: true
    field :locale,   as: :text
    field :created_at, as: :date_time, sortable: true, only_on: :index
  end
end

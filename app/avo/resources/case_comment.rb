class Avo::Resources::CaseComment < Avo::BaseResource
  self.includes = [ :case_study ]
  self.title = :author_name
  self.default_view_type = :table
  self.default_sort_column = :created_at
  self.default_sort_direction = :desc

  def fields
    field :id,          as: :id
    field :case_study,  as: :belongs_to
    field :author_name, as: :text
    field :status,      as: :select, options: CaseComment.statuses.keys.index_by(&:itself),
          display_with_value: true
    field :body,        as: :textarea
    field :created_at,  as: :date_time, sortable: true, only_on: :index
  end

  def actions
    action Avo::Actions::ApproveComment
    action Avo::Actions::HideComment
  end

  def filters
    filter Avo::Filters::CommentStatusFilter, default: "pending"
  end
end

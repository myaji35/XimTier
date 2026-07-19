class Avo::Filters::CommentStatusFilter < Avo::Filters::SelectFilter
  self.name = "댓글 상태"

  def apply(request, query, value)
    return query if value == "all"

    query.where(status: value)
  end

  def options
    {
      "검토 대기" => "pending",
      "게시됨" => "approved",
      "전체" => "all"
    }
  end
end

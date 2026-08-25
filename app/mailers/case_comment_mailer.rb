class CaseCommentMailer < ApplicationMailer
  def admin_notification(comment)
    @comment = comment
    mail(
      to: admin_recipients,
      subject: "[XimTier] 새 댓글 승인 대기 — #{comment.case_study.title} (#{comment.author_name})"
    )
  end
end

class CaseComment < ApplicationRecord
  belongs_to :case_study

  enum :status, { pending: 0, approved: 1, hidden: 2 }

  validates :author_name, presence: true, length: { maximum: 60 }
  validates :body,        presence: true, length: { maximum: 2000 }

  scope :visible, -> { approved.order(created_at: :asc) }
end

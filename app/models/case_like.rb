class CaseLike < ApplicationRecord
  belongs_to :case_study

  validates :visitor_token, presence: true,
                            uniqueness: { scope: :case_study_id }
end

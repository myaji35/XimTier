class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :demo_request

  validates :body, presence: true, length: { maximum: 4000 }

  scope :recent, -> { order(created_at: :asc) }
end

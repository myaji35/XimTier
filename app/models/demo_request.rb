class DemoRequest < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_one_attached :data_file

  enum :status, {
    pending:   0,
    scheduled: 1,
    completed: 2,
    cancelled: 3
  }

  validates :data_description, presence: true, length: { maximum: 2000 }
  validates :locale, inclusion: { in: %w[ko en] }

  scope :recent, -> { order(created_at: :desc) }
  scope :open,   -> { where(status: %w[pending scheduled]) }
end

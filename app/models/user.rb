class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :demo_requests, dependent: :destroy
  has_many :comments, dependent: :destroy

  enum :industry, {
    other:         0,
    manufacturing: 1,
    hospital:      2,
    public_sector: 3,
    finance:       4,
    smart_city:    5
  }

  validates :locale, inclusion: { in: %w[ko en] }

  scope :admins, -> { where(admin: true) }

  def display_name
    name.presence || email
  end
end

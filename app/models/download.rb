class Download < ApplicationRecord
  enum :asset, {
    ir_deck_ko:      0,
    ir_deck_en:      1,
    ai_engine_deck:  2
  }

  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP
  validates :name,  presence: true, length: { maximum: 100 }
  validates :download_token, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[ko en] }

  before_validation :ensure_token, on: :create

  scope :recent, -> { order(created_at: :desc) }

  ASSET_FILES = {
    "ir_deck_ko"     => "XimTier_IR_PreSeed_v1.pdf",
    "ir_deck_en"     => "XimTier_IR_PreSeed_v1_en.pdf",
    "ai_engine_deck" => "XAISimTier_AI_Decision_Engine.pdf"
  }.freeze

  def asset_path
    ir_dir = Rails.root.join("public", "ir")
    primary = ir_dir.join(ASSET_FILES.fetch(asset, ASSET_FILES["ir_deck_ko"]))
    return primary if File.exist?(primary)

    if asset == "ir_deck_en"
      ir_dir.join(ASSET_FILES["ir_deck_ko"])
    else
      primary
    end
  end

  def increment_download!
    self.class.where(id: id).update_all("downloaded_count = downloaded_count + 1, updated_at = CURRENT_TIMESTAMP")
  end

  private

  def ensure_token
    self.download_token ||= SecureRandom.hex(20)
  end
end

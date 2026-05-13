class MarketVennComponent < ApplicationComponent
  attr_reader :di, :xai, :prescriptive, :caption

  def initialize(di:, xai:, prescriptive:, caption:)
    @di = di
    @xai = xai
    @prescriptive = prescriptive
    @caption = caption
  end
end

class MarketFunnelComponent < ApplicationComponent
  attr_reader :tam, :sam, :som, :target_callout

  def initialize(tam:, sam:, som:, target_callout:)
    @tam = tam
    @sam = sam
    @som = som
    @target_callout = target_callout
  end
end

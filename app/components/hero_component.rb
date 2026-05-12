class HeroComponent < ApplicationComponent
  renders_one :actions
  renders_one :indicators
  attr_reader :eyebrow, :headline, :subhead

  def initialize(eyebrow:, headline:, subhead: nil)
    @eyebrow = eyebrow
    @headline = headline
    @subhead = subhead
  end
end

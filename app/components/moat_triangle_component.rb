class MoatTriangleComponent < ApplicationComponent
  attr_reader :sovereignty, :regulated, :reverse

  def initialize(sovereignty:, regulated:, reverse:)
    @sovereignty = sovereignty
    @regulated = regulated
    @reverse = reverse
  end
end

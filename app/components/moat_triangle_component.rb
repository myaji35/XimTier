class MoatTriangleComponent < ApplicationComponent
  attr_reader :sovereignty, :regulated, :reverse

  def initialize(sovereignty:, regulated:, reverse:)
    @sovereignty = sovereignty
    @regulated = regulated
    @reverse = reverse
  end

  def points_in_order
    [
      [:sovereignty, sovereignty, { cx: 230, cy: 70,  icon: "🔒" }],
      [:reverse,     reverse,     { cx: 70,  cy: 320, icon: "🔄" }],
      [:regulated,   regulated,   { cx: 390, cy: 320, icon: "⚖" }]
    ]
  end

  def card_order
    [
      [:sovereignty, sovereignty],
      [:regulated,   regulated],
      [:reverse,     reverse]
    ]
  end

  # vertex 두 끝점 → data-pair 문자열 ("a-b" with consistent order)
  LINE_PAIRS = [
    [:sovereignty, :reverse],
    [:sovereignty, :regulated],
    [:reverse,     :regulated]
  ].freeze

  def line_pair_attr(pair)
    pair.map(&:to_s).join("-")
  end
end

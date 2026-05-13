class CardComponent < ApplicationComponent
  attr_reader :icon, :eyebrow, :title, :body, :quote, :stat_value, :stat_label, :highlighted

  def initialize(title:, body: nil, icon: nil, eyebrow: nil, quote: nil, stat_value: nil, stat_label: nil, highlighted: false)
    @icon = icon
    @eyebrow = eyebrow
    @title = title
    @body = body
    @quote = quote
    @stat_value = stat_value
    @stat_label = stat_label
    @highlighted = highlighted
  end

  def card_classes
    base = "rounded-xl border p-6 md:p-8 transition"
    base += highlighted ? " border-[#2563EB] shadow-[0_10px_30px_-12px_rgba(11,19,45,0.18)] bg-white" : " border-[#e5e9f0] bg-white hover:border-[#2563EB] hover:shadow-[0_10px_30px_-12px_rgba(11,19,45,0.18)]"
    base
  end
end

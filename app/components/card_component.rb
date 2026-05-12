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
    base = "rounded-xl border bg-slate-900/40 p-6 md:p-8 transition"
    base += highlighted ? " border-cyan-400/50 shadow-[0_0_32px_rgba(34,211,238,0.15)]" : " border-slate-800/80 hover:border-slate-700"
    base
  end
end

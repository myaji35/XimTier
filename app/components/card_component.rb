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
    classes = ["card-airbnb", "shadow-card-hover", "transition"]
    classes << "ring-1 ring-[var(--color-rausch)]" if highlighted
    classes.join(" ")
  end
end

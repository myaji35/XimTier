class BrandLogoComponent < ApplicationComponent
  attr_reader :variant, :size, :show_wordmark

  # variant: :light (canvas bg, ink wordmark) / :dark (dark bg, white wordmark)
  # X 4-blade 심볼 유지 — Rausch 단색 워드마크 전환은 ISS-013 후속 결정 사항.
  def initialize(variant: :light, size: 28, show_wordmark: true)
    @variant = variant
    @size = size
    @show_wordmark = show_wordmark
  end

  def symbol_id
    variant == :dark ? "x-mark-light" : "x-mark"
  end

  def text_color_class
    variant == :dark ? "text-white" : "text-ink-airbnb"
  end

  def wordmark_color_class
    variant == :dark ? "text-white" : "text-ink-airbnb"
  end
end

class BrandLogoComponent < ApplicationComponent
  attr_reader :variant, :size, :show_wordmark

  # variant: :light (light bg, navy bottom blades) / :dark (dark bg, white bottom blades)
  def initialize(variant: :light, size: 28, show_wordmark: true)
    @variant = variant
    @size = size
    @show_wordmark = show_wordmark
  end

  def symbol_id
    variant == :dark ? "x-mark-light" : "x-mark"
  end

  def text_color_class
    variant == :dark ? "text-white" : "text-[#0B132D]"
  end
end

class CtaComponent < ApplicationComponent
  attr_reader :label, :href, :variant

  VARIANTS = {
    primary:   "btn-rausch",
    secondary: "btn-secondary-airbnb",
    ghost:     "btn-tertiary-airbnb",
    pill:      "pill-rausch"
  }.freeze

  def initialize(label:, href:, variant: :primary)
    @label = label
    @href = href
    @variant = variant
  end

  def classes
    VARIANTS.fetch(variant, VARIANTS[:primary])
  end
end

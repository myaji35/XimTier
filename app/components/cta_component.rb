class CtaComponent < ApplicationComponent
  attr_reader :label, :href, :variant

  VARIANTS = {
    primary:   "inline-flex items-center justify-center rounded-md bg-cyan-400 px-6 py-3 font-semibold text-slate-950 hover:bg-cyan-300 transition",
    secondary: "inline-flex items-center justify-center rounded-md border border-slate-700 px-6 py-3 font-semibold text-slate-100 hover:border-cyan-400/60 hover:text-cyan-300 transition",
    ghost:     "inline-flex items-center justify-center px-4 py-2 text-sm text-slate-300 hover:text-cyan-300 transition"
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

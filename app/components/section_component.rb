class SectionComponent < ApplicationComponent
  renders_one :actions
  attr_reader :eyebrow, :title, :lead, :tone, :anchor

  def initialize(eyebrow: nil, title:, lead: nil, tone: :default, anchor: nil)
    @eyebrow = eyebrow
    @title = title
    @lead = lead
    @tone = tone
    @anchor = anchor
  end

  def section_classes
    base = "relative max-w-6xl mx-auto px-6 py-20 md:py-24"
    base += " border-t border-slate-800/60" unless tone == :hero
    base
  end

  def title_classes
    tone == :hero ? "text-4xl md:text-6xl font-bold leading-tight text-slate-50" :
                    "text-3xl md:text-4xl font-bold text-slate-50"
  end
end

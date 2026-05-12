class IconComponent < ApplicationComponent
  attr_reader :name, :size

  SVGS = {
    lock: <<~SVG,
      <path d="M5 11h14M7 11V8a5 5 0 0110 0v3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" fill="none"/>
      <rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" stroke-width="1.6" fill="none"/>
    SVG
    calculator: <<~SVG,
      <rect x="5" y="3" width="14" height="18" rx="2" stroke="currentColor" stroke-width="1.6" fill="none"/>
      <path d="M8 7h8M8 11h2m2 0h2m2 0h.01M8 15h2m2 0h2m2 0h.01M8 19h2m2 0h2m2 0h.01" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" fill="none"/>
    SVG
    scale: <<~SVG,
      <path d="M12 3v18M5 7h14M6 7l-3 7a4 4 0 008 0l-3-7M18 7l-3 7a4 4 0 008 0l-3-7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    SVG
    factory: <<~SVG,
      <path d="M3 21V10l5 3V10l5 3V10l5 3v8H3z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round" fill="none"/>
      <path d="M7 17h2m2 0h2m2 0h2" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
    SVG
    heart: <<~SVG,
      <path d="M12 21s-7-4.35-7-10a4 4 0 017-2.65A4 4 0 0119 11c0 5.65-7 10-7 10z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round" fill="none"/>
    SVG
    building: <<~SVG,
      <rect x="5" y="3" width="14" height="18" rx="1" stroke="currentColor" stroke-width="1.6" fill="none"/>
      <path d="M9 7h2m2 0h2M9 11h2m2 0h2M9 15h2m2 0h2M11 21v-4h2v4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" fill="none"/>
    SVG
    city: <<~SVG,
      <path d="M3 21V11l4-2v12M11 21V7l4-2v16M19 21V13l2-1v9H3" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round" fill="none"/>
    SVG
    arrows: <<~SVG,
      <path d="M7 7l-3 3 3 3M4 10h7M17 17l3-3-3-3M20 14h-7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    SVG
    bolt: <<~SVG,
      <path d="M13 3L4 14h7l-1 7 9-11h-7l1-7z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round" fill="none"/>
    SVG
    chart: <<~SVG,
      <path d="M4 19h16M6 16v-5M10 16V8M14 16v-3M18 16V6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" fill="none"/>
    SVG
  }.freeze

  def initialize(name:, size: 24)
    @name = name.to_sym
    @size = size
  end

  def svg_inner
    SVGS[name] || ""
  end
end

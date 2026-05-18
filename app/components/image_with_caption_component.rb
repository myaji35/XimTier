class ImageWithCaptionComponent < ApplicationComponent
  attr_reader :src, :alt, :caption, :source, :tone, :aspect, :rounded

  TONES = {
    grayscale: "filter: grayscale(100%) contrast(1.05);",
    desaturate: "filter: saturate(0.45) contrast(1.02);",
    color: ""
  }.freeze

  ASPECTS = {
    "16:9" => "aspect-ratio: 16/9;",
    "4:3"  => "aspect-ratio: 4/3;",
    "1:1"  => "aspect-ratio: 1/1;",
    "21:9" => "aspect-ratio: 21/9;",
    auto:    ""
  }.freeze

  # src       — asset path (e.g. "industry/manufacturing.jpg")
  # alt       — accessibility text (REQUIRED)
  # caption   — visible caption under image (optional)
  # source    — attribution required by Unsplash/CC0 license (REQUIRED for industry/charts)
  # tone      — :grayscale (default, brand-dna v0.5.0) / :desaturate / :color
  # aspect    — "16:9" (default) / "4:3" / "1:1" / "21:9" / :auto
  # rounded   — true (default) applies card-airbnb corners
  def initialize(src:, alt:, caption: nil, source: nil, tone: :grayscale, aspect: "16:9", rounded: true)
    raise ArgumentError, "alt is required for ImageWithCaption" if alt.blank?

    @src = src
    @alt = alt
    @caption = caption
    @source = source
    @tone = tone
    @aspect = aspect
    @rounded = rounded
  end

  def figure_classes
    classes = ["overflow-hidden"]
    classes << "rounded-[12px]" if rounded
    classes << "border-hairline-soft"
    classes.join(" ")
  end

  def img_style
    [ASPECTS[aspect] || ASPECTS["16:9"], "object-fit: cover; width: 100%; display: block;", TONES[tone]].join(" ")
  end
end

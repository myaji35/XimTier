class WorkflowStepsComponent < ApplicationComponent
  attr_reader :steps, :tone

  # tone: :dark (default — section-dark에 사용) | :light
  def initialize(steps:, tone: :dark)
    @steps = steps
    @tone = tone.to_sym
  end

  def text_color; tone == :dark ? "#e6e8f0" : "#0B132D"; end
  def muted_color; tone == :dark ? "#8a94ac" : "#697386"; end
  def card_bg; tone == :dark ? "#0e1838" : "#ffffff"; end
  def card_border; tone == :dark ? "rgba(255,255,255,0.08)" : "#e5e9f0"; end
end

class StatIndicatorComponent < ApplicationComponent
  attr_reader :value, :label
  def initialize(value:, label:)
    @value = value
    @label = label
  end
end

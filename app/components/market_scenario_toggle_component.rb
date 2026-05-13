class MarketScenarioToggleComponent < ApplicationComponent
  attr_reader :bull, :base_case, :worst

  def initialize(bull:, base:, worst:)
    @bull = bull
    @base_case = base
    @worst = worst
  end
end

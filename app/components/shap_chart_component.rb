class ShapChartComponent < ApplicationComponent
  POSITIVE_COLOR = "#00C8C8".freeze
  NEGATIVE_COLOR = "#2563EB".freeze
  AXIS_COLOR     = "rgba(11,19,45,0.18)".freeze
  GRID_BG        = "#F2F4F7".freeze

  attr_reader :rows, :row_height, :gap, :label_width, :num_width

  def initialize(rows: 5, row_height: 24, gap: 12, label_width: 88, num_width: 60)
    @rows         = rows
    @row_height   = row_height
    @gap          = gap
    @label_width  = label_width
    @num_width    = num_width
  end

  def row_indices
    (0...rows).to_a
  end

  def chart_height
    rows * row_height + (rows - 1) * gap
  end
end

module ActiveRecord
  module Calculations
    def median(column_name)
      percentile_cont(0.5).within_group(column_name)
    end
  end
end

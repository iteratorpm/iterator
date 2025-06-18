class ChangeIterationStartDate < ActiveRecord::Migration[8.0]
  def change
    change_column_default :projects, :iteration_start_day, from: 0, to: 1
    change_column_default :projects, :velocity_strategy, from: 0, to: 2
  end
end

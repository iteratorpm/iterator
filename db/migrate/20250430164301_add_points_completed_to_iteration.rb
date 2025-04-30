class AddPointsCompletedToIteration < ActiveRecord::Migration[8.0]
  def change
    add_column :iterations, :points_completed, :integer, default: 0, null: false
  end
end

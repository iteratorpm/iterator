class RenamePointsToEstimate < ActiveRecord::Migration[8.0]
  def change
    rename_column :stories, :points, :estimate
  end
end

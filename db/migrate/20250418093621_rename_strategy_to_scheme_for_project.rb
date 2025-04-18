class RenameStrategyToSchemeForProject < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :velocity_strategy, :velocity_scheme
  end
end

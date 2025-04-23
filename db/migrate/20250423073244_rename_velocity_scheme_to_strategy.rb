class RenameVelocitySchemeToStrategy < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :velocity_scheme, :velocity_strategy
  end
end

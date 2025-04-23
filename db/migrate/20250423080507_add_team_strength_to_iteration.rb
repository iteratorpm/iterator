class AddTeamStrengthToIteration < ActiveRecord::Migration[8.0]
  def change
    add_column :iterations, :team_strength, :integer, null: false, default: 100
  end
end

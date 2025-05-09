class AddDefaultVelocityToProjects < ActiveRecord::Migration[8.0]
  def change
    change_column_default :projects, :velocity, from: nil, to: 0
  end
end

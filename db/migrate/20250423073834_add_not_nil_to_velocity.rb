class AddNotNilToVelocity < ActiveRecord::Migration[8.0]
  def change
    Project.where(velocity: nil).update_all(velocity: 10)
    change_column_null :projects, :velocity, false
  end
end

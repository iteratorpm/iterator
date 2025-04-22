class ChangeTimeZoneToStringOnProjects < ActiveRecord::Migration[8.0]
  def change
    change_column :projects, :time_zone, :string
  end
end

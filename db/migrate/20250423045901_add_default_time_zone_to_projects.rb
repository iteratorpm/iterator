class AddDefaultTimeZoneToProjects < ActiveRecord::Migration[8.0]
  def change
    change_column_default :projects, :time_zone, from: nil, to: "Eastern Time (US & Canada)"

    Project.where(time_zone: nil).update_all(time_zone: "Eastern Time (US & Canada)")

    change_column_null :projects, :time_zone, false

    change_column_default :users, :time_zone, from: nil, to: "Eastern Time (US & Canada)"

    User.where(time_zone: nil).update_all(time_zone: "Eastern Time (US & Canada)")

    change_column_null :users, :time_zone, false
  end
end

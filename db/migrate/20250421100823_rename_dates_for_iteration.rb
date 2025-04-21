class RenameDatesForIteration < ActiveRecord::Migration[8.0]
  def change
    rename_column :iterations, :starts_on, :start_date
    rename_column :iterations, :ends_on, :end_date
  end
end

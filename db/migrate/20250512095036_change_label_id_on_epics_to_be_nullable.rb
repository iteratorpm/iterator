class ChangeLabelIdOnEpicsToBeNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :epics, :label_id, true
  end
end

class ChangePriorityDefault < ActiveRecord::Migration[8.0]
  def change
    change_column_default :stories, :priority, from: 2, to: 0
  end
end

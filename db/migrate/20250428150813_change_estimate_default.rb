class ChangeEstimateDefault < ActiveRecord::Migration[8.0]
  def change

    Story.where(estimate: nil).update_all(estimate: -1)

    change_column_default :stories, :estimate, from: nil, to: -1

    change_column_null :stories, :estimate, false
  end
end

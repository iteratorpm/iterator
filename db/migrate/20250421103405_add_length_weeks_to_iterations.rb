class AddLengthWeeksToIterations < ActiveRecord::Migration[8.0]
  def change
    add_column :iterations, :length_weeks, :integer
  end
end

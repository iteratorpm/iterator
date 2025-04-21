class AddNumberToIterations < ActiveRecord::Migration[8.0]
  def change
    add_column :iterations, :number, :integer, null: false, default: 0
  end
end

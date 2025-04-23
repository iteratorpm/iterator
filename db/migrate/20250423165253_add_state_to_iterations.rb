class AddStateToIterations < ActiveRecord::Migration[8.0]
  def change
    remove_column :iterations, :current
    add_column :iterations, :state, :integer, default: 0, null: false
    add_index :iterations, :number
    add_index :iterations, :state
  end
end

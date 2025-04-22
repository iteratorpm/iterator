class AddIterationColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :iterations, :velocity, :integer
    add_column :iterations, :current, :boolean, default: false, null: false
  end
end

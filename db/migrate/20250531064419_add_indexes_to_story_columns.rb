class AddIndexesToStoryColumns < ActiveRecord::Migration[8.0]
  def change
    add_index :stories, [:project_id, :state]
    add_index :stories, [:iteration_id, :state]
    add_index :stories, [:project_id, :state, :iteration_id]
  end
end

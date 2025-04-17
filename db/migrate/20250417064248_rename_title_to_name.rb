class RenameTitleToName < ActiveRecord::Migration[8.0]
  def change
    rename_column :epics, :title, :name
    rename_column :stories, :title, :name
    rename_column :projects, :title, :name
  end
end

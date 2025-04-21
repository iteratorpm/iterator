class AddDeadlineToStories < ActiveRecord::Migration[8.0]
  def change
    add_column :stories, :deadline, :date
  end
end

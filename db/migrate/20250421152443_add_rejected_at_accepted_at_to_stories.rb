class AddRejectedAtAcceptedAtToStories < ActiveRecord::Migration[8.0]
  def change
    add_column :stories, :rejected_at, :datetime
    add_column :stories, :accepted_at, :datetime
    add_column :stories, :started_at, :datetime
  end
end

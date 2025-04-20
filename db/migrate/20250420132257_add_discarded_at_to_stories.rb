class AddDiscardedAtToStories < ActiveRecord::Migration[8.0]
  def change
    add_column :stories, :discarded_at, :datetime
    add_index :stories, :discarded_at
  end
end

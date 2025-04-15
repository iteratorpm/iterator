class CreateStoryFollowers < ActiveRecord::Migration[8.0]
  def change
    create_table :story_followers do |t|
      t.references :story, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index [:story_id, :user_id], unique: true
    end
  end
end

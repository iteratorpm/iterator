class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :commentable, polymorphic: true, null: false
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps

      t.index [:commentable_type, :commentable_id]
    end
  end
end

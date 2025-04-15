class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.integer :status, default: 0
      t.text :comment
      t.references :story, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

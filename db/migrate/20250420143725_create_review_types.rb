class CreateReviewTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :review_types do |t|
      t.string :name
      t.boolean :hidden, default: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateCsvExports < ActiveRecord::Migration[8.0]
  def change
    create_table :csv_exports do |t|
      t.references :project, null: false, foreign_key: true
      t.string :filename
      t.integer :filesize
      t.integer :status, default: 0, null: false
      t.text :options

      t.timestamps
    end
  end
end

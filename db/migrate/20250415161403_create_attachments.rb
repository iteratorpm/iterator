class CreateAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :attachments do |t|
      t.string :filename, null: false
      t.string :content_type
      t.integer :file_size
      t.string :file_path, null: false
      t.references :attachable, polymorphic: true, null: false
      t.references :uploader, null: false, foreign_key: { to_table: :users }

      t.timestamps

      t.index [:attachable_type, :attachable_id]
    end
  end
end

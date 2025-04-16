class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 1
      t.timestamps

      t.index [:organization_id, :user_id], unique: true
    end
  end
end

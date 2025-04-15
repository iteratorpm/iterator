class CreateUserFields < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :name, :string, default: "", null: false
    add_column :users, :initials, :string, default: "", null: false

    add_index :users, :username, unique: true
  end
end

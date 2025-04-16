class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :time_zone, :string
    add_column :users, :api_token, :string
  end
end

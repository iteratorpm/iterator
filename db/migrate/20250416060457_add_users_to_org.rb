class AddUsersToOrg < ActiveRecord::Migration[8.0]
  def change
    add_reference :organizations, :user, foreign_key: true
  end
end

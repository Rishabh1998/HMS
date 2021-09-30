class AddRoleIdToAdminUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_users, :role_id, :integer
  end
end

class AddCanToPermissions < ActiveRecord::Migration[6.1]
  def change
    add_column :permissions, :can, :string
  end
end

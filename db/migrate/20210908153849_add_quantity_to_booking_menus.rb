class AddQuantityToBookingMenus < ActiveRecord::Migration[6.1]
  def change
    add_column :booking_menus, :quantity, :integer, :default => 1
  end
end

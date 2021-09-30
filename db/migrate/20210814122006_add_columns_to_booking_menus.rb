class AddColumnsToBookingMenus < ActiveRecord::Migration[6.1]
  def change
    add_column :booking_menus, :payment_status, :boolean, :default => false
    add_column :booking_menus, :payment_mode, :integer, :default => 1
  end
end

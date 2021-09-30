class RemovePaymentColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :booking_menus, :payment_status
    remove_column :booking_menus, :payment_mode
    remove_column :bookings, :advance_payment_mode
    
  end
end

class RenameColumnInBooking < ActiveRecord::Migration[6.1]
  def change
    rename_column :bookings, :room_price_per_day, :room_charges
    rename_column :bookings, :payment_status, :advance_payment_mode
  end
end

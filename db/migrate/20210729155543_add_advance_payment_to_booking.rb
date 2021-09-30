class AddAdvancePaymentToBooking < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :advance_payment, :decimal, precision: 10, scale: 2
    remove_column :bookings, :room_id
  end
end

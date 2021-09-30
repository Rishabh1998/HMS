class AddFlagsToBookings < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :checkin_receipt_printed, :boolean, :default => false
    add_column :bookings, :checkout_receipt_printed, :boolean, :default => false
  end
end

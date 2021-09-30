class AddBookingTypeToBooking < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :booking_type, :integer
  end
end

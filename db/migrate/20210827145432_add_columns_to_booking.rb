class AddColumnsToBooking < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :room_type, :integer
    add_column :bookings, :stay_during, :integer
  end
end

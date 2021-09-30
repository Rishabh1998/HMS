class CreateBookingRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :booking_rooms do |t|
      t.integer :booking_id
      t.integer :room_id

      t.timestamps
    end
  end
end

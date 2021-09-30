class CreateBookingGuests < ActiveRecord::Migration[6.1]
  def change
    create_table :booking_guests do |t|
      t.integer :booking_id
      t.integer :guest_id

      t.timestamps
    end
  end
end

class CreateBookings < ActiveRecord::Migration[6.1]
  def change
    create_table :bookings do |t|
      t.datetime :check_in_date
      t.datetime :check_out_date
      t.integer :status, :default => 1
      t.integer :payment_status, :default => 1
      t.integer :room_id
      t.decimal :room_price_per_day, precision: 10, scale: 2
      t.integer :customer_id
      t.datetime :checked_in_time
      t.datetime :checked_out_time
      
      t.timestamps
    end
  end
end

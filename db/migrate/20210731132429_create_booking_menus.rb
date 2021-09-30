class CreateBookingMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :booking_menus do |t|
      t.integer :booking_id
      t.integer :menu_id

      t.timestamps
    end
  end
end

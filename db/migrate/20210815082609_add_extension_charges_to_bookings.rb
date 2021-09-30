class AddExtensionChargesToBookings < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :extension_charges, :decimal, precision: 10, scale: 2, :default => 0.0
  end
end

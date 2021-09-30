class RemoveAdvancePayment < ActiveRecord::Migration[6.1]
  def change
    remove_column :bookings, :advance_payment
  end
end

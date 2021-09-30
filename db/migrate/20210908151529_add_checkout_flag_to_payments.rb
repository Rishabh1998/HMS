class AddCheckoutFlagToPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :payments, :checkout_flag, :boolean, :default => false
  end
end

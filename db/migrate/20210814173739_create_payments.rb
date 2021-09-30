class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.integer :payment_mode, default: 1
      t.references :objectable, polymorphic: true, null: false
      t.integer :type, default: 1
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end

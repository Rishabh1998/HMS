class AddImageToCustomers < ActiveRecord::Migration[6.1]
  def change
    add_column :customers, :image, :string
    add_column :guests, :image, :string
  end
end

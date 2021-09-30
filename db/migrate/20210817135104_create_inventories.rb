class CreateInventories < ActiveRecord::Migration[6.1]
  def change
    create_table :inventories do |t|
      t.string :name
      t.integer :quantity, :default => 0

      t.timestamps
    end
  end
end

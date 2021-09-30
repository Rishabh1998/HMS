class CreateMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :menus do |t|
      t.string :name
      t.decimal :price, :decimal, precision: 10, scale: 2
      t.text :description
      t.integer :menu_category_id

      t.timestamps
    end
  end
end

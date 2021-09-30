class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms do |t|
      t.string :number
      t.integer :status, :default => 1

      t.timestamps
    end
  end
end

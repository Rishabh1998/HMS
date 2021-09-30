class CreateRoomPictures < ActiveRecord::Migration[6.1]
  def change
    create_table :room_pictures do |t|
      t.integer :room_id
      t.boolean :verified, :default => false

      t.timestamps
    end
  end
end

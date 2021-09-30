class AddColumnToRoomPictures < ActiveRecord::Migration[6.1]
  def change
    add_column :room_pictures, :washroom_image, :string
    add_column :room_pictures, :room_image, :string
    add_column :room_pictures, :laundry, :string
  end
end

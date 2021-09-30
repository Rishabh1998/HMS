class RoomPicture < ApplicationRecord
    belongs_to :room
    has_one_attached :washroom_image, :dependent => :destroy
    has_one_attached :room_image, :dependent => :destroy
    has_one_attached :laundry, :dependent => :destroy

    has_many_attached :additional_images, :dependent => :destroy
end

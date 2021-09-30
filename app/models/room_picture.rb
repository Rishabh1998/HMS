class RoomPicture < ApplicationRecord
    belongs_to :room

    mount_uploader :washroom_image, ImageUploader
    mount_uploader :room_image, ImageUploader
    mount_uploader :laundry, ImageUploader

end

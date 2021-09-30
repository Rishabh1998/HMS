class RoomPicture < ApplicationRecord
    belongs_to :room

    mount_uploader :washroom_image, ImageUploader
    mount_uploader :room_image, ImageUploader
    mount_uploader :laundry, ImageUploader

    validates_presence_of :washroom_image
    validates_presence_of :room_image
    validates_presence_of :laundry
    
end

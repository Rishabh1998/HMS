class Guest < ApplicationRecord
    has_many :booking_guests
    mount_uploader :image, ImageUploader
end

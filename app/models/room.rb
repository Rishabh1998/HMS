class Room < ApplicationRecord

    enum status: {'ready': 1, 'occupied': 2, 'need_cleaning': 3}
    has_many :booking_rooms
    has_many :bookings, through: :booking_rooms
    has_many :room_pictures
    accepts_nested_attributes_for :room_pictures, allow_destroy: true

end

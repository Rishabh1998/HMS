class Guest < ApplicationRecord
    has_many :booking_guests
    has_one_attached :image, :dependent => :destroy
end

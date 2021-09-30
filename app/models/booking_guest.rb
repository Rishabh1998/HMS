class BookingGuest < ApplicationRecord
    belongs_to :booking
    belongs_to :guest
end

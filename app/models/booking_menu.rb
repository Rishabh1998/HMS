class BookingMenu < ApplicationRecord
    belongs_to :menu
    belongs_to :booking
end

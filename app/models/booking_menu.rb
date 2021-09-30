class BookingMenu < ApplicationRecord
    belongs_to :menu
    belongs_to :booking
    enum payment_mode: {'unpaid': 1, 'google_pay': 2, 'phonepe': 3, 'card': 4, 'cash': 5, 'oyo_paid': 6}
end

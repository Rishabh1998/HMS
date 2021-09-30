class BookingMenu < ApplicationRecord
    belongs_to :menu
    belongs_to :booking
    has_many :payments, as: :objectable

    accepts_nested_attributes_for :payments
    # enum payment_mode: {'unpaid': 1, 'google_pay': 2, 'phonepe': 3, 'card': 4, 'cash': 5, 'oyo_paid': 6}
end

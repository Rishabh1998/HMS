class Booking < ApplicationRecord

    enum status: {'booked': 1, 'checkin': 2, 'checkout': 3, 'no_show': 4}
    enum payment_status: {'unpaid': 1, 'google_pay': 2, 'phonepe': 3, 'card': 4, 'cash': 5}
    belongs_to :customer
    has_many :booking_rooms
    has_many :rooms, through: :booking_rooms
    has_many :booking_guests
    has_many :guests, through: :booking_guests


    accepts_nested_attributes_for :rooms
    accepts_nested_attributes_for :guests

    before_update :change_room_status

    def change_room_status
        status = 'ready'
        status = 'occupied' if self.status_changed? and self.status == 'checkin'
        status = 'need_cleaning' if self.status_changed? and self.status == 'checkout'
        Room.where(id: self.room_ids).update_all(status: status) if self.room_ids.present? and self.status_changed? and self.status != 'no_show'
    end
end

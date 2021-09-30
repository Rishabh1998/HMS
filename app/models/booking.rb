class Booking < ApplicationRecord

    enum status: {'booked': 1, 'checkin': 2, 'checkout': 3, 'no_show': 4}
    enum payment_status: {'unpaid': 1, 'google_pay': 2, 'phonepe': 3, 'card': 4, 'cash': 5, 'partially_paid': 6}
    belongs_to :customer
    has_many :booking_rooms
    has_many :rooms, through: :booking_rooms
    has_many :booking_guests
    has_many :guests, through: :booking_guests
    has_many :booking_menus
    has_many :menus, through: :booking_menus


    accepts_nested_attributes_for :rooms
    accepts_nested_attributes_for :guests
    accepts_nested_attributes_for :booking_menus

    before_update :change_room_status
    before_update :check_advance_payment
    before_update :change_status

    def check_advance_payment
        self.payment_status = 'partially_paid' if self.advance_payment.present?
    end

    def change_status
        self.checked_in_time = Time.now if self.status_changed? and self.status == 'checkin'
        self.checked_out_time = Time.now if self.status_changed? and self.status == 'checkout'
    end

    def change_room_status
        status = 'ready'
        status = 'occupied' if self.status_changed? and self.status == 'checkin'
        status = 'need_cleaning' if self.status_changed? and self.status == 'checkout'
        Room.where(id: self.room_ids).update_all(status: status) if self.room_ids.present? and self.status_changed? and self.status != 'no_show'
    end

    def total_room_price
        checkout = self.status == 'checkout' ? self.checked_out_time.to_date : self.check_out_date.to_date
        checkin = self.status == 'checkout' ? self.checked_in_time.to_date : self.check_in_date.to_date
        (self.room_price_per_day || 0) * (checkout - checkin).to_i * (self.room_ids.present? ? self.room_ids.count : 1)
    end

    def total_menu_price
        self.menus&.sum(:price)
    end

    def total_price
        self.total_room_price + self.total_menu_price
    end

end

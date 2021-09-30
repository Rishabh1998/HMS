class Booking < ApplicationRecord

    enum status: {'booked': 1, 'checkin': 2, 'checkout': 3, 'no_show': 4}
    # enum advance_payment_mode: {'unpaid': 1, 'google_pay': 2, 'phonepe': 3, 'card': 4, 'cash': 5, 'oyo_paid': 6}
    enum room_type: {'ac': 1, 'non_ac': 2}
    enum stay_during: {'day': 1, 'night': 2}
    enum booking_type: {'walkin': 1, 'oyo': 2}

    belongs_to :customer
    has_many :booking_rooms, dependent: :destroy
    has_many :rooms, through: :booking_rooms
    has_many :booking_guests, dependent: :destroy
    has_many :guests, through: :booking_guests
    has_many :booking_menus, dependent: :destroy
    has_many :menus, through: :booking_menus
    has_many :payments, as: :objectable, dependent: :destroy

    accepts_nested_attributes_for :rooms
    accepts_nested_attributes_for :guests
    accepts_nested_attributes_for :booking_menus
    accepts_nested_attributes_for :payments

    before_update :change_room_status
    before_update :change_status
    after_update :reduce_inventory, :if => Proc.new {|booking| booking.status == "checkout"}

    def change_status
        self.checked_in_time = Time.zone.now if self.status_changed? and self.status == 'checkin'
        self.checked_out_time = Time.zone.now if self.status_changed? and self.status == 'checkout'
    end

    def reduce_inventory
        soaps = Inventory.find_by(name: 'Soaps')
        soaps.update(quantity: soaps.quantity - 1) unless soaps.nil? or self.checkout_receipt_printed
    end

    def change_room_status
        if self.status_changed? and self.status == 'checkin'
            self.room_ids.each do |room_id|
                Room.find(room_id).room_pictures.delete_all
            end
        end
        status = 'ready'
        status = 'occupied' if self.status_changed? and self.status == 'checkin'
        status = 'need_cleaning' if self.status_changed? and self.status == 'checkout'
        Room.where(id: self.room_ids).update_all(status: status) if self.room_ids.present? and self.status_changed? and self.status != 'no_show'
    end

    def total_menu_price
        self&.menus&.sum('price * quantity')
    end

    def total_room_charges
        (self&.room_charges || 0) + (self&.extension_charges || 0)
    end

    def total_price
        self.total_room_charges + self.total_menu_price
    end

    def advance_payment
        self.payments.where(payment_type: 'advance')&.sum(:amount)
    end

    def advance_payment_mode
        self.payments.where(payment_type: 'advance')&.first&.payment_mode
    end

    def additional_payment_amount
        self.payments.where(payment_type: 'other')&.sum(:amount)
    end

    def checkout_payment
        self.payments.where(payment_type: 'checkout').where.not(payment_mode: 'unpaid')&.sum(:amount)
    end

    def food_payment
        total = 0
        self.booking_menus.each do |booking_menu|
            total += booking_menu.payments.where.not(payment_mode: 'unpaid')&.sum(:amount)
        end
        total - self.checkout_food_payment
    end

    def pending_room_charges
        self.total_room_charges - (self.advance_payment + self.additional_payment_amount + self.checkout_payment)
    end

    def pending_food_charges
        self.total_menu_price - self.food_payment
    end

    def total_pending_charges
        self.pending_room_charges + self.pending_food_charges
    end

    def checkout_payment_paid
        self.payments.where(payment_type: "checkout").first
    end

    def checkout_food_payment
        amount = 0
        if self.status == "checkout"
            self.booking_menus.each do |booking_menu|
                amount += booking_menu.payments.where(checkout_flag: true)&.sum(:amount)
            end
        end
        amount
    end

    def total_checkout_payment
        self.checkout_payment_paid.amount + self.checkout_food_payment
    end

end

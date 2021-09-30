class Customer < ApplicationRecord

    has_many :bookings
    has_many :guests, through: :bookings

    validates_uniqueness_of :phone_number

    has_one_attached :image, :dependent => :destroy

    accepts_nested_attributes_for :bookings, allow_destroy: false

    after_update :cleanup

    def cleanup
        self.bookings.where(check_in_date: nil).delete_all
    end

end

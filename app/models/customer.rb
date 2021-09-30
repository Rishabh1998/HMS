class Customer < ApplicationRecord

    has_many :bookings

    validates_uniqueness_of :phone_number

    has_one_attached :id_proof

    accepts_nested_attributes_for :bookings, allow_destroy: false

end

class Payment < ApplicationRecord
  belongs_to :objectable, polymorphic: true

  enum payment_mode: {'unpaid': 1, 'google_pay': 2, 'phonepe': 3, 'card': 4, 'cash': 5, 'oyo_paid': 6}
  enum payment_type: {'advance': 1, 'checkout': 2, 'food': 3, 'other': 4}

  before_save :set_payment_time
  before_create :food_payment

  def food_payment
    if self.payment_type == 'food'
      self.amount = self.objectable.menu.price * self.objectable.quantity
    end
  end

  def set_payment_time
    self.paid_at = Time.zone.now if self.payment_mode_changed? and self.payment_mode != 'unpaid'
  end
end

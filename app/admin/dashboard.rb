ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column class: 'div-box' do
        panel "Total Bookings Today" do
          Booking.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        end
      end
      column class: 'div-box' do
        panel "Total Checkins Today" do
          Booking.where(checked_in_time: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        end
      end
      column class: 'div-box' do
        panel "Total Checkout Today" do
          Booking.where(checked_out_time: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        end
      end
    end

    pending_food_payment = Payment.where(payment_mode: 'unpaid', payment_type: 'food')
    total_payment = Payment.where(paid_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).where.not(payment_mode: 'unpaid')
    columns do 
      column class: 'div-box' do
        panel "Total Payments Today" do
          "Rs. " + total_payment&.sum(:amount).to_s
        end
      end
      column class: 'div-box' do
        panel "Pending Food Payments" do
          "Rs. " + pending_food_payment&.sum(:amount).to_s
        end
      end
    end

    columns do 
      column class: 'div-box' do
        panel "GPAY" do
          total_payment.where(payment_mode: 'google_pay')&.sum(:amount).to_s
        end
      end
      column class: 'div-box' do
        panel "Phonepe" do
          total_payment.where(payment_mode: 'phonepe')&.sum(:amount).to_s
        end
      end
      column class: 'div-box' do
        panel "Card Payment" do
          total_payment.where(payment_mode: 'card')&.sum(:amount).to_s
        end
      end
      column class: 'div-box' do
        panel "OYO PAID" do
          total_payment.where(payment_mode: 'oyo_paid')&.sum(:amount).to_s
        end
      end
      column class: 'div-box' do
        panel "Cash Payment" do
          total_payment.where(payment_mode: 'cash')&.sum(:amount).to_s
        end
      end
    end

  bookings = Booking.where(status: 'checkin')
  h3 "Pending Payments"

    table class: "index_table index" do
      tr do
        th "Booking ID", class: 'col'
        th "Customer Name", class: 'col'
        th "Pending Room Charges", class: 'col'
        th "Pending Food Charges", class: 'col'
        th "Total Pending", class: 'col'
      end
      bookings.each do |b|
        tr do
          td "#"+ b.id.to_s, class: 'col'
          td b.customer.name, class: 'col'
          td "Rs. " + b.pending_room_charges.to_s, class: 'col'
          td "Rs. " + b.pending_food_charges.to_s, class: 'col'
          td "Rs. " + b.total_pending_charges.to_s, class: 'col'
        end
      end
    end

  end
end

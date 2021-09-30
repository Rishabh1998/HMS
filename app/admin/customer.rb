ActiveAdmin.register Customer, as: 'Customer' do

    permit_params :name, :email, :phone_number, bookings_attributes: [:id, :check_in_date, :check_out_date, :room_price_per_day, :advance_payment, room_ids: [], guests_attributes: [:id, :name]]

    controller do
      def create
        customer = Customer.find_or_create_by(phone_number: params["customer"]["phone_number"])
        customer.update(customer_params)
        redirect_to admin_booking_path
      end

      private
      def customer_params
        params["customer"].permit(:email, :phone_number, :name, bookings_attributes: [:id, :check_in_date, :check_out_date])
      end
    end

    index do
      selectable_column
      column :id
      column :name
      column :email
      column :phone_number
  
      actions
    end
  
    filter :name
    filter :email
    filter :phone_number
  
    form do |f|
      inputs 'Customer' do
        f.input :name
        f.input :email
        f.input :phone_number, label: 'Phone Number'
        if f.object.bookings.empty?
          f.object.bookings << Booking.new
        end
        f.has_many :bookings, allow_remove: false, new_record: false do |booking|
          booking.input :check_in_date, as: :datepicker, input_html: {autocomplete: "off"}
          booking.input :check_out_date, as: :datepicker, input_html: {autocomplete: "off"}
          booking.input :room_price_per_day
          booking.input :advance_payment
          # booking.input :room_ids, as: :select, :collection => Room.all.collect {|room| [room.number, room.id] }, multiple: true
          booking.has_many :guests do |guest|
            guest.input :name
          end
        end
      end
      
      actions
    end

end

  
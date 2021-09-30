ActiveAdmin.register Customer, as: 'Customer' do

    permit_params :name, :email, :phone_number, :image, bookings_attributes: [:id, :check_in_date, :check_out_date, :room_charges, room_ids: [], booking_guest_ids: [], guests_attributes: [:id, :name, :image], payments_attributes: [:id, :payment_mode, :payment_type, :amount]]

    actions :all, except: [:destroy]
    controller do
      def create
        customer = Customer.find_or_create_by(phone_number: params["customer"]["phone_number"])
        customer.update(customer_params)
        redirect_to admin_bookings_path
      end

      private
      def customer_params
        params["customer"].permit(:email, :phone_number, :name, bookings_attributes: [:id, :check_in_date, :check_out_date, :room_charges, room_ids: [], booking_guest_ids: [], guests_attributes: [:id, :name, :image], payments_attributes: [:id, :payment_mode, :payment_type, :amount]])
      end
    end

    index do |object|
      selectable_column
      column :id
      column :name
      column :email
      column :phone_number
      column :actions do |object|
        link_to "View", admin_customer_path(object.id), {:class=>"button button-false" }
      end
      column "" do |object|
        link_to "New Booking", edit_admin_customer_path(object.id), {:class=>"button button-false width-200px" }
      end
    end
  
    filter :name
    filter :email
    filter :phone_number
  
    form do |f|
      inputs 'Customer' do
        f.input :name
        f.input :email
        f.input :phone_number, label: 'Phone Number'
        f.input :image, label: "Id proof", :as => :file, :hint => f.object.image.present? ? image_tag(rails_blob_url(f.object.image), :size => 150) : ""
          
        f.object.bookings << Booking.new
        object_booking = f.object.bookings.last
        old_guests = f.object.guests
        f.has_many :bookings, allow_remove: false, new_record: false do |booking|
          if object_booking.nil? or booking.object.id == object_booking.id
            booking.input :check_in_date, as: :datepicker, input_html: {autocomplete: "off"}
            booking.input :check_out_date, as: :datepicker, input_html: {autocomplete: "off"}
            booking.input :room_charges
            booking.object.payments << Payment.new(payment_type: 'advance') if booking.object.payments.empty?
            booking.has_many :payments, allow_remove: false, new_record: false do |payment|
              payment.input :payment_mode, label: 'Advance Payment Mode'
              payment.input :amount, label: 'Advance Payment'
            end
            booking.input :booking_guest_ids, as: :select, :collection => old_guests.pluck(:name, :id), multiple: true if old_guests.present?
            # booking.input :room_ids, as: :select, :collection => Room.all.collect {|room| [room.number, room.id] }, multiple: true
            booking.has_many :guests do |guest|
              guest.input :name
              guest.input :image, label: "Id proof", :as => :file, :hint => guest.object.image.present? ? image_tag(rails_blob_url(guest.object.image), :size => 150) : ""
            end
          end
        end
      end
      f.actions do
        f.action :submit, as: :input, label: 'Create Booking'
        f.cancel_link({action: "index"})
      end
    end

    show do |object|
      attributes_table do
        row :name
        row :phone_number
        row :email
        row 'Id Proof' do 
          object.image.present? ? image_tag(rails_blob_url(object.image), :size => 150) : ""
        end
        if object.guests.present?
          div class: 'guests' do 
            h3 'Guests'
            div class: 'guests_table' do 
              table class: 'table' do 
                tr do
                  th 'Name'
                  th 'ID Proof'
                end
              object.guests.each do |guest|
                  tr do 
                    td guest.name
                    td guest.image.present? ? image_tag(rails_blob_url(guest.image), :size => 150) : ""
                  end
              end
            end
          end
        end
      end
    end
  end
    
end

  

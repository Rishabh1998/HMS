ActiveAdmin.register Booking, as: 'Checkout' do

    permit_params :status, :room_charges, :check_out_date, :check_in_date, room_ids: []
    
    actions :all, except: [:new, :destroy, :edit]
    menu :parent => "Bookings", :priority => 2

    member_action :no_show, method: :put do
      Booking.find(params[:id]).update(status: 'no_show')
      redirect_to admin_bookings_path
    end

    action_item only: :index do
      link_to 'Booking', admin_bookings_path, class: 'custom_buttons button green'
    end

    action_item only: :index do
      link_to 'In House', admin_in_house_guests_path, class: 'custom_buttons button yellow'
    end

    action_item only: :index do
      link_to 'Checkout', admin_checkouts_path, class: 'custom_buttons button red'
    end

    action_item only: :index do
      link_to 'Rooms', admin_rooms_path, class: 'custom_buttons button blue'
    end

    controller do
      def scoped_collection
        super.checkout
      end
    end

    index do
      selectable_column
      column :id
      column :customer
      column :check_in_date do |object|
        object.checked_in_time&.strftime("%d %B %Y - %I:%M %p") unless object.checked_in_time.nil?
      end
      column :check_out_date do |object|
        object.checked_out_time&.strftime("%d %B %Y - %I:%M %p") unless object.checked_out_time.nil?
      end
      column :status
      column :rooms do |object|
        object.rooms.pluck(:number)
      end
      column :room_charges

      column "" do |object|
        object.status_before_type_cast < 2 ? (link_to "Mark as No Show", no_show_admin_booking_path(object), {method: :put, :class=>"button button-false width-200px" }) : ""
      end
      column :booking_type 
      column :room_type
      column :actions do |object|
        object.status_before_type_cast < 3 ? (link_to "#{Booking.statuses.key(object.status_before_type_cast + 1).humanize}", edit_admin_booking_path(object, status: Booking.statuses.key(object.status_before_type_cast + 1)), {:class=>"button button-true" }) : ""
      end
      actions
    end
  
    filter :check_in_date
    filter :status
    filter :room
    filter :customer
    filter :booking_type
    filter :room_type

    form do |f|
      inputs 'Booking' do 
        ready_rooms = Room.ready
        rooms = ready_rooms.or(Room.where(id: f.object.room_ids))
        f.input :status, :input_html => { :id => "booking_status" }
        f.input :room_ids, label: 'Allot Rooms', as: :select, :collection => rooms.collect {|room| [room.number, room.id] }, multiple: true
      end
      actions
    end

    show do |object|
      attributes_table do
        row :check_in_date
        row :check_out_date
        row :status
        row :room_type
        row :booking_type
        row :stay_during
        row :customer
        row :checked_in_time
        row :checked_out_time
        row :room_charges
        row :extension_charges
        row :total_room_charges
        row :total_menu_price
        row :total_price
        row :advance_payment
        row :additional_payment_amount
        row :food_payment
        row :pending_room_charges
        row :pending_food_charges
        row :total_pending_charges
        row :checkin_receipt_printed, id: 'checkin_receipt_printed'
        row :checkout_receipt_printed, id: 'checkout_receipt_printed'
        row :rooms do |object|
          object.rooms.pluck(:number)
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
                td object.customer.name
                td object.customer.image.present? ? image_tag(object.customer.image.url, style: "width: 350px"): ""
              object.guests.each do |guest|
                  tr do
                    td guest.name
                    td guest.image.present? ? image_tag(guest.image.url, style: "width: 350px")  : ''
                  end
              end
            end
          end
        end
      end

      end
    end
  
  end
  
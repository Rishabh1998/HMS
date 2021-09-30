ActiveAdmin.register Booking, as: 'In House Guests' do

    permit_params :status, :check_out_date, :check_in_date, :extension_charges, room_ids: [], menu_ids: [], payments_attributes: [:id, :payment_mode, :payment_type, :amount], booking_menus_attributes: [:id, :menu_id, payments_attributes: [:id, :payment_mode, :payment_type, :amount]]
    
    actions :all, except: [:destroy, :new]
    menu :parent => "Bookings", :priority => 1

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
      before_action :cleanup, only: :index

      def update
        resource.update(params["booking"].permit(:status, :check_out_date, :extension_charges, room_ids: [], payments_attributes: [:id, :payment_mode, :payment_type, :amount], booking_menus_attributes: [:id, :menu_id, payments_attributes: [:id, :payment_mode, :payment_type, :amount]]))
        if resource.status == "checkout"
          pdf = render_to_string pdf: "receipt"+resource.id.to_s, template: "admin/booking/checkout_receipt.pdf.erb", page_height: '210', page_width: '58', margin:  {top: 10, bottom: 0, left: 3, right: 0}, encoding: "UTF-8"

          # then save to a file
          save_path = Rails.root.join('public/pdfs','filename.pdf')
          File.open(save_path, 'wb') do |file|
            file << pdf
          end
          redirect_to admin_checkout_path(params[:id], checkout_receipt_id: resource.id)
        else
          redirect_to admin_in_house_guest_path(params[:id])
        end
      end

      def cleanup
        Booking.where(check_in_date: nil).delete_all
      end
      
      def scoped_collection
        super.checkin
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
        object.check_out_date&.strftime("%d %B %Y") unless object.check_out_date.nil?
      end
      column :status
      column :rooms do |object|
        object.rooms.pluck(:number)
      end
      column :room_charges
      column :booking_type 
      column :room_type
      column :actions do |object|
        object.status_before_type_cast < 3 ? (link_to "#{Booking.statuses.key(object.status_before_type_cast + 1).humanize}", edit_admin_in_house_guest_path(object, status: Booking.statuses.key(object.status_before_type_cast + 1)), {:class=>"button button-true" }) : ""
      end
      actions
    end
  
    filter :check_in_date
    filter :status
    filter :booking_type
    filter :room_type
    filter :room
    filter :customer

    form do |f|
      inputs 'Booking' do 
        ready_rooms = Room.ready
        rooms = ready_rooms.or(Room.where(id: f.object.room_ids))
        f.input :status, :input_html => { :id => "booking_status" }
        f.input :room_ids, label: 'Allot Rooms', as: :select, :collection => rooms.collect {|room| [room.number, room.id] }, multiple: true, :input_html => {disabled: true}
        f.has_many :booking_menus, new_record: params["status"] != "checkout" do |menu|
          if params["status"] != 'checkout'
            menu.input :menu_id, as: :select, :collection => Menu.all.collect{|m| [m.name, m.id]}
            menu.object.payments << Payment.new(payment_type: 'food') if menu.object.payments.empty?
            menu.has_many :payments, heading: false, allow_remove: false, new_record: false do |payment|
              payment.input :payment_mode
              payment.input :payment_type, :input_html => {value: 'food'}, as: :hidden
                # payment.input :amount, label: 'Advance Payment'
            end
          elsif menu.object.payments.first&.payment_mode == "unpaid"
            menu.input :menu_id, as: :select, :collection => Menu.all.collect{|m| [m.name, m.id]}
            # menu.object.payments << Payment.new(payment_type: 'food') if menu.object.payments.empty?
            menu.has_many :payments, heading: false, new_record: false do |payment|
              payment.input :payment_mode
              payment.input :payment_type, :input_html => {value: 'food'}, as: :hidden
                # payment.input :amount, label: 'Advance Payment'
            end
          end
        end
        if params["status"] == "checkout"
          h3 'Pending Payment'
          f.object.payments << Payment.new(payment_type: 'checkout') if f.object.payments.where(payment_type: 'checkout').empty?
          f.has_many :payments, heading: false, allow_remove: false, new_record: false do |payment|
            if payment.object.payment_type == "checkout"
              h3 "Rs. " + f.object.total_pending_charges.to_s
              payment.input :payment_mode, label: 'Payment Mode'
              payment.input :amount, label: 'Payment Amount', :input_html => {value: f.object.pending_room_charges}, as: :hidden
              payment.input :payment_type, :input_html => {value: 'checkout'}, as: :hidden
            end
          end
        else 
          f.input :check_out_date, label: 'Extend Current Checkout Date', as: :datepicker, input_html: {autocomplete: "off", value: f.object&.check_out_date&.strftime("%d %B %Y")}
          f.input :extension_charges
          h3 'Add Payments'
          f.has_many :payments, heading: false, allow_remove: false do |payment|
            if payment.object.payment_type == "other" or payment.object.id == nil
              payment.input :payment_mode, label: 'Payment Mode'
              payment.input :amount, label: 'Payment Amount'
              payment.input :payment_type, :input_html => {value: 'other'}, as: :hidden
            end
          end
        end
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
  
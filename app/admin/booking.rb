ActiveAdmin.register Booking, as: 'Bookings' do

    permit_params :status, :room_charges, :room_type, :booking_type, :stay_during, :check_out_date, :check_in_date, room_ids: [], menu_ids: [], payments_attributes: [:id, :payment_mode, :payment_type, :amount], booking_menus_attributes: [:id, :menu_id, :quantity, payments_attributes: [:id, :payment_mode, :payment_type, :amount]]

    actions :all, except: [:destroy]
    menu :parent => "Bookings", :priority => 1

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

    member_action :no_show, method: :put do
      Booking.find(params[:id]).update(status: 'no_show')
      redirect_to admin_bookings_path
    end

    member_action :printed_flags, method: :get do
      booking = Booking.find(params[:id])
      render json: {check_in: booking.checkin_receipt_printed, check_out: booking.checkout_receipt_printed}
    end

    member_action :check_in_printed, method: :get do
      booking = Booking.find(params[:id])
      booking.update!(checkin_receipt_printed: true)
      render json: {message: "success"}
    end

    member_action :check_out_printed, method: :get do
      booking = Booking.find(params[:id])
      booking.update!(checkout_receipt_printed: true)
      render json: {message: "success"}
    end

    controller do
      before_action :cleanup, only: :index

      def new
        redirect_to new_admin_customer_path
      end

      def cleanup
        Booking.where(check_in_date: nil).delete_all
      end
      
      def update
        resource.update(params["booking"].permit(:status, :room_charges, :room_type, :booking_type, :stay_during, :check_out_date, :check_in_date, room_ids: [], payments_attributes: [:id, :payment_mode, :payment_type, :amount], booking_menus_attributes: [:id, :menu_id, :quantity, payments_attributes: [:id, :payment_mode, :payment_type, :amount]]))
        if resource.status == 'checkin'
          pdf = render_to_string pdf: "receipt"+resource.id.to_s, template: "admin/booking/checkin_receipt.pdf.erb", page_height: '210', page_width: '58', margin:  {top: 10, bottom: 0, left: 3, right: 0}, encoding: "UTF-8"

          # then save to a file
          save_path = Rails.root.join('public/pdfs','filename.pdf')
          File.open(save_path, 'wb') do |file|
            file << pdf
          end
          # system("lpr", save_path.to_s) 
          # render  pdf: "receipt"+resource.id.to_s,
          #         locals: { booking: resource },
          #         template: 'admin/booking/receipt.pdf.erb',
          #         disposition: 'attachment',
          #         formats: :html, encoding: 'utf8'
          redirect_to admin_in_house_guest_path(params[:id], checkin_receipt_id: resource.id)
        else
          redirect_to admin_booking_path(params[:id])
        end
      end

      def scoped_collection
        super.booked
      end

      def edit
        redirect_to admin_in_house_guest_path(params[:id]) if Booking.find(params[:id]).status == "checkin"
        redirect_to admin_checkout_path(params[:id]) if Booking.find(params[:id]).status == "checkout"
      end

      def show
        redirect_to admin_in_house_guest_path(params[:id]) if Booking.find(params[:id]).status == "checkin"
        redirect_to admin_checkout_path(params[:id]) if Booking.find(params[:id]).status == "checkout"
      end

    end

    index do
      selectable_column
      column :id
      column :customer
      column :check_in_date do |object|
        object.check_in_date&.strftime("%d %B %Y") unless object.check_in_date.nil?
      end
      column :check_out_date do |object|
        object.check_out_date&.strftime("%d %B %Y") unless object.check_out_date.nil?
      end
      column :status
      column :rooms do |object|
        object.rooms.pluck(:number)
      end
      column :room_charges
      column :actions do |object|
        object.status_before_type_cast < 3 ? (link_to "#{Booking.statuses.key(object.status_before_type_cast + 1).humanize}", edit_admin_booking_path(object, status: Booking.statuses.key(object.status_before_type_cast + 1)), {:class=>"button button-true" }) : ""
      end
      column :booking_type
      column :room_type
      column "" do |object|
        object.status_before_type_cast < 2 ? (link_to "Mark as No Show", no_show_admin_booking_path(object), {method: :put, :class=>"button button-false width-200px" }) : ""
      end
      actions
    end
  
    filter :check_in_date
    filter :status
    filter :room
    filter :customer

    form do |f|
      inputs 'Booking' do 
        ready_rooms = Room.ready
        rooms = ready_rooms.or(Room.where(id: f.object.room_ids))
        f.input :status, :input_html => { :id => "booking_status" }
        f.input :room_type
        f.input :booking_type
        f.input :stay_during
        f.input :room_ids, label: 'Allot Rooms', as: :select, :collection => rooms.collect {|room| [room.number, room.id] }, multiple: true
        f.object.payments << Payment.new(payment_type: 'advance') if f.object.payments.empty?
          f.has_many :payments, new_record: false do |payment|
              payment.input :payment_mode, label: 'Advance Payment Mode'
              payment.input :amount, label: 'Advance Payment'
          end
        f.has_many :booking_menus do |menu|
          menu.input :menu_id, as: :select, :collection => Menu.all.collect{|m| [m.name, m.id]}
          menu.input :quantity, :input_html => {disabled: menu.object.id.present?}
          menu.object.payments << Payment.new(payment_type: 'food') if menu.object.payments.empty?
          menu.has_many :payments, heading: false, allow_remove: false, new_record: false do |payment|
            payment.input :payment_mode
            payment.input :payment_type, :input_html => {value: 'food'}, as: :hidden
              # payment.input :amount, label: 'Advance Payment'
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
        row :customer
        row :checked_in_time
        row :checked_out_time
        row :room_charges
        row :total_room_charges
        row :total_menu_price
        row :total_price
        row :booking_type
        row :room_type

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
  
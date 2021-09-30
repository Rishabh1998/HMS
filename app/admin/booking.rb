ActiveAdmin.register Booking, as: 'Bookings' do

    permit_params :status, :room_charges, :check_out_date, :check_in_date, :payment_status, room_ids: [], menu_ids: [], booking_menus_attributes: [:id, :menu_id, :payment_mode, :payment_status]

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

    controller do
      before_action :cleanup, only: :index

      def new
        redirect_to new_admin_customer_path
      end

      def cleanup
        Booking.where(check_in_date: nil).delete_all
      end
      
      def update
        resource.update(params["booking"].permit(:status, :room_charges, :check_out_date, :check_in_date, room_ids: [], booking_menus_attributes: [:id, :menu_id, :payment_mode, :payment_status]))
        if resource.status == 'checkin'
          pdf = render_to_string pdf: "receipt"+resource.id.to_s, template: "admin/booking/checkin_receipt.pdf.erb", encoding: "UTF-8"

          # then save to a file
          save_path = Rails.root.join('pdfs','filename.pdf')
          File.open(save_path, 'wb') do |file|
            file << pdf
          end
          system("lpr", save_path.to_s) or raise "LPR error"
          # render  pdf: "receipt"+resource.id.to_s,
          #         locals: { booking: resource },
          #         template: 'admin/booking/receipt.pdf.erb',
          #         disposition: 'attachment',
          #         formats: :html, encoding: 'utf8'
          redirect_to admin_in_house_guest_path(params[:id])
        else
          redirect_to admin_booking_path(params[:id])
        end
      end

      def scoped_collection
        super.booked
      end
    end

    index do
      selectable_column
      column :id
      column :customer
      column :check_in_date do |object|
        object.check_in_date.strftime("%d %B %Y") unless object.check_in_date.nil?
      end
      column :check_out_date do |object|
        object.check_out_date.strftime("%d %B %Y") unless object.check_out_date.nil?
      end
      column :status
      column :rooms do |object|
        object.rooms.pluck(:number)
      end
      column :room_charges
      column :advance_payment
      column :actions do |object|
        object.status_before_type_cast < 3 ? (link_to "#{Booking.statuses.key(object.status_before_type_cast + 1).humanize}", edit_admin_booking_path(object, status: Booking.statuses.key(object.status_before_type_cast + 1)), {:class=>"button button-true" }) : ""
      end
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
        f.input :room_ids, label: 'Allot Rooms', as: :select, :collection => rooms.collect {|room| [room.number, room.id] }, multiple: true
        f.has_many :booking_menus do |menu|
          menu.input :menu_id, as: :select, :collection => Menu.all.collect{|m| [m.name, m.id]}
          menu.input :payment_status
          menu.input :payment_mode
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
        row :payment_status
        row :advance_payment
        row :room_charges
        row :total_room_price
        row :total_menu_price
        row :total_price
      end
    end
  
  end
  
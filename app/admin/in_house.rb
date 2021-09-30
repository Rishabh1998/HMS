ActiveAdmin.register Booking, as: 'In House Guests' do

    permit_params :status, :check_out_date, :check_in_date, room_ids: [], menu_ids: [], booking_menus_attributes: [:id, :menu_id, :payment_status, :payment_mode]
    
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
        resource.update(params["booking"].permit(:status, room_ids: [], booking_menus_attributes: [:id, :menu_id, :payment_mode, :payment_status]))
        if resource.status == "checkout"
          redirect_to admin_checkout_path(params[:id])
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
  
      column :actions do |object|
        object.status_before_type_cast < 3 ? (link_to "#{Booking.statuses.key(object.status_before_type_cast + 1).humanize}", edit_admin_in_house_guest_path(object, status: Booking.statuses.key(object.status_before_type_cast + 1)), {:class=>"button button-true" }) : ""
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
        row :advance_payment
        row :advance_payment_mode
        row :room_charges
        row :total_room_price
        row :total_menu_price
        row :total_price
      end
    end
  
  end
  
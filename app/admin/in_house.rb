ActiveAdmin.register Booking, as: 'In House Guests' do

    permit_params :status, :room_price_per_day, :check_out_date, :check_in_date, :payment_status, room_ids: [], menu_ids: [], booking_menus_attributes: [:id, :menu_id]
    
    actions :all, except: [:destroy, :new]
    menu :parent => "Bookings", :priority => 1

    member_action :no_show, method: :put do
      Booking.find(params[:id]).update(status: 'no_show')
      redirect_to admin_bookings_path
    end

    controller do
      before_action :cleanup, only: :index

      def update
        resource.update(params["booking"].permit(:status, :payment_status, room_ids: [], booking_menus_attributes: [:id, :menu_id]))
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
      column :payment_status
      column :rooms do |object|
        object.rooms.pluck(:number)
      end
      column :room_price_per_day
  
      column :actions do |object|
        object.status_before_type_cast < 3 ? (link_to "#{Booking.statuses.key(object.status_before_type_cast + 1).humanize}", edit_admin_in_house_guest_path(object, status: Booking.statuses.key(object.status_before_type_cast + 1)), {:class=>"button button-true" }) : ""
      end
      actions
    end
  
    filter :check_in_date
    filter :status
    filter :payment_status
    filter :room
    filter :customer

    form do |f|
      inputs 'Booking' do 
        ready_rooms = Room.ready
        rooms = ready_rooms.or(Room.where(id: f.object.room_ids))
        f.input :status, :input_html => { :id => "booking_status" }
        f.input :room_ids, label: 'Allot Rooms', as: :select, :collection => rooms.collect {|room| [room.number, room.id] }, multiple: true
        f.input :payment_status
        f.has_many :booking_menus do |menu|
          menu.input :menu_id, as: :select, :collection => Menu.all.collect{|m| [m.name, m.id]}
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
        row :room_price_per_day
        row :total_room_price
        row :total_menu_price
        row :total_price
      end
    end
  
  end
  
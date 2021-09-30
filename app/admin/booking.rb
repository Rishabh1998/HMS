ActiveAdmin.register Booking, as: 'Booking' do

    actions :all, except: [:delete]
    permit_params :status, :room_price_per_day, :check_out_date, :check_in_date, :payment_status, room_ids: []
    

    controller do
      def new
        redirect_to new_admin_customer_path
      end
    end

    index do
      selectable_column
      column :id
      column :customer
      column :check_in_date
      column :check_out_date
      column :status
      column :payment_status
      column :rooms do |object|
        object.rooms.pluck(:number)
      end
      column :room_price_per_day
  
      actions
    end
  
    filter :check_in_date
    filter :status
    filter :payment_status
    filter :room

    form do |f|
      inputs 'Booking' do 
        f.input :status
        f.input :room_ids, as: :select, :collection => Room.all.collect {|room| [room.number, room.id] }, multiple: true
        f.input :payment_status
      end
      actions
    end
  
  end
  
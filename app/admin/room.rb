ActiveAdmin.register Room, as: 'Room' do

    actions :all, except: [:show, :destroy]

    permit_params :number, :status, :description, room_pictures_attributes: [:id, :washroom_image, :room_image, :laundry, :verified]

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
    
    index do |object|
      selectable_column
      column :id
      column :number
      column :description
      column :status do |object|
        pictures = object.room_pictures.present?
        not_verified = object.room_pictures.pluck(:verified).include? false
        link_to ((pictures && not_verified) ? "Needs Verification" : "#{object.status.humanize}"), "", {:class=>"button width-200px", :id => "room_status_#{pictures && not_verified ? 'verification' : object.status}" }
      end
      actions
    end
  
    filter :number
    filter :status

    form do |f|
      inputs 'Room' do 
        f.input :number
        f.input :status
        f.input :description
        f.object.room_pictures << RoomPicture.new if f.object.room_pictures.where(verified: false).empty?
        f.has_many :room_pictures, id: "room_pictures#{current_admin_user.role.name == "Admin"? "admin" : ""}" do |room_picture|
          if room_picture.object.verified == false
            room_picture.input :washroom_image, :as => :file, :hint => room_picture.object.washroom_image.present? ? image_tag(rails_blob_url(room_picture.object.washroom_image), :size => 150) : "", :input_html => {accept: "image/*", capture: '', id: 'washroom_image'}, required: true
            room_picture.input :room_image, :as => :file, :hint => room_picture.object.room_image.present? ? image_tag(rails_blob_url(room_picture.object.room_image), :size => 150) : "", :input_html => {accept: "image/*", capture: '', id: 'room_image'}, required: true
            room_picture.input :laundry, :as => :file, :hint => room_picture.object.laundry.present? ? image_tag(rails_blob_url(room_picture.object.laundry), :size => 150) : "", :input_html => {accept: "image/*", capture: '', id: 'laundry'}, required: true
            if current_admin_user.role.name == "Admin" || current_admin_user.role.name == "admin"
              room_picture.input :verified, :input_html => {id: 'verified'}
            end
          end
        end
      end
      actions
    end
  
  end
  
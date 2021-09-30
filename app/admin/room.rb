ActiveAdmin.register Room, as: 'Room' do

    actions :all, except: [:show]
    permit_params :number, :status, room_pictures_attributes: [:id, :washroom_image, :room_image, :laundry]


    index do |object|
      selectable_column
      column :id
      column :number
      column :description
      column :status do |object|
        pictures = object.room_pictures.present?
        link_to (pictures ? "Needs Verification" : "#{object.status.humanize}"), "", {:class=>"button width-200px", :id => "room_status_#{pictures ? 'verification' : object.status}" }
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
        if f.object.status == "need_cleaning"
          f.object.room_pictures << RoomPicture.new if f.object.room_pictures.where(verified: false).nil?
          f.has_many :room_pictures do |room_picture|
            if room_picture.object.verified == false
              room_picture.input :washroom_image, :as => :file, :hint => room_picture.object.washroom_image.present? ? image_tag(rails_blob_url(room_picture.object.washroom_image), :size => 150) : ""
              room_picture.input :room_image, :as => :file, :hint => room_picture.object.room_image.present? ? image_tag(rails_blob_url(room_picture.object.room_image), :size => 150) : ""
              room_picture.input :laundry, :as => :file, :hint => room_picture.object.laundry.present? ? image_tag(rails_blob_url(room_picture.object.laundry), :size => 150) : ""
            end
          end
        end
      end
      actions
    end
  
  end
  
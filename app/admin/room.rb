ActiveAdmin.register Room, as: 'Room' do

    actions :all, except: [:show]
    permit_params :number, :status


    index do
      selectable_column
      column :id
      column :number
      column :status
  
      actions
    end
  
    filter :number
    filter :status

    form do |f|
      inputs 'Booking' do 
        f.input :number
        f.input :status
      end
      actions
    end
  
  end
  
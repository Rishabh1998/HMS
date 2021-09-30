ActiveAdmin.register Inventory, as: 'Inventory' do

    actions :all, except: [:show, :destroy]
    permit_params :name, :quantity


    index do |object|
      selectable_column
      column :id
      column :name
      column :quantity

      actions
    end
  
    filter :name

    form do |f|
      inputs 'Menu' do 
        f.input :name
        f.input :quantity
      end
      actions
    end
  
  end
  
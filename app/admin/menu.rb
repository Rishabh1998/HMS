ActiveAdmin.register Menu, as: 'Menu' do

    actions :all, except: [:show]
    permit_params :name, :menu_category_id, :description, :price


    index do |object|
      selectable_column
      column :id
      column :name
      column :description
      column :price

      actions
    end
  
    filter :name

    form do |f|
      inputs 'Menu' do 
        f.input :name
        f.input :menu_category, as: :select
        f.input :price
        f.input :description
      end
      actions
    end
  
  end
  
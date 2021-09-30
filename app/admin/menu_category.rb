ActiveAdmin.register MenuCategory, as: 'Menu Category' do

    actions :all, except: [:show]
    permit_params :name


    index do |object|
      selectable_column
      column :id
      column :name
      actions
    end
  
    filter :name

    form do |f|
      inputs 'Menu Category' do 
        f.input :name
      end
      actions
    end
  
  end
  
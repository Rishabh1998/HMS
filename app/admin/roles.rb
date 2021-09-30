ActiveAdmin.register Role, as: 'Roles' do

  permit_params :name, permission_ids: []
  index do
    selectable_column
    column :name

    actions
  end

  filter :name

  form do |f|
    inputs 'Role'do
      f.input :name
      f.input :permission_ids, label: "Permissions", as: :select, collection: Permission.all.map {|p| ["Can #{p.can} #{p.name}", p.id]}, multiple: true
    end
    actions
  end


end
